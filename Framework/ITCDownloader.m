//
//  ITCDownloader.m
//  StoreSales
//
//  Created by sonson on 11/08/25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ITCDownloader.h"

#import "NSDictionary+HTTP.h"
#import "ITCTool.h"
#import "KeychainAccessor.h"

static ITCDownloader *sharedManager = nil;

@implementation ITCDownloader

+ (ITCDownloader *)sharedManager {
	if (sharedManager == nil) {
		sharedManager = [ITCDownloader new];
	}
	return sharedManager;
}

+ (NSArray*)dailyListToBeDownloaded {
	NSMutableArray *list = [NSMutableArray array];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setLocale:[NSLocale systemLocale]];
	[dateFormatter setDateFormat:@"yyyyMMdd"];
	
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	
	NSTimeInterval base = [NSDate timeIntervalSinceReferenceDate];
	
	int offsetOfDays = 1;
	int numberOfDays = 13;
	
	for (int i = offsetOfDays; i < numberOfDays + offsetOfDays; i++) {
		NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:base - i * 24 * 3600];
		
		NSString *dateString = [dateFormatter stringFromDate:date];
		
		[list addObject:dateString];
	}
	
	[dateFormatter release];
	[usLocale release];
	
	return [NSArray arrayWithArray:list];
}

+ (NSArray*)weeklyListToBeDownloaded {
	NSMutableArray *list = [NSMutableArray array];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	
	[dateFormatter setLocale:usLocale];
	[dateFormatter setDateFormat:@"yyyyMMdd"];
	
	NSString *keyDateString = @"20110529";
	
	NSDate *keyDate = [dateFormatter dateFromString:keyDateString];
	
	NSLog(@"%@", keyDateString);
	NSLog(@"%@", [dateFormatter stringFromDate:keyDate]);
	
	int numberOfDiffWeeks = ([NSDate timeIntervalSinceReferenceDate] - [keyDate timeIntervalSinceReferenceDate]) / (3600 * 24 * 7);
	
	NSLog(@"%d", numberOfDiffWeeks);
	
	NSDate *latestWeekEndDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[keyDate timeIntervalSinceReferenceDate] + (3600 * 24 * 7) * numberOfDiffWeeks];
	
	NSLog(@"%@", [dateFormatter stringFromDate:latestWeekEndDate]);
	
	int numberOfWeeksToBeDownloaded = 13;
	
	for (int i = 0; i < numberOfWeeksToBeDownloaded; i++) {
		NSTimeInterval temp = [keyDate timeIntervalSinceReferenceDate] + (3600 * 24 * 7) * (numberOfDiffWeeks - i);
		NSString *tempDayString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:temp]];
		[list addObject:tempDayString];
	}
	
	[usLocale release];
	
	return [NSArray arrayWithArray:list];
}

- (void)downloadReports {
	NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"iTunesConnectUserName"];
	NSString *vndnumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"iTunesConnectVNDNumber"];
	
	if ([username length] && [vndnumber length]) {
		[self performSelectorInBackground:@selector(tryToDownloadReports) withObject:nil];
	}
	else {
		[self showGrowlMessageWithTitle:NSLocalizedString(@"Error", nil) description:NSLocalizedString(@"Please input username or VND number for iTunes Connect via Preference.", nil)];
		
		[UIAppDelegate.mainMenuController stopAnimation];
		[UIAppDelegate.mainMenuController setEnabled:YES];
		[UIAppDelegate.fileSendController restartBonjourServer];
	}
}

- (BOOL)download:(NSString*)dateString dateType:(NSString*)dateType username:(NSString*)username password:(NSString*)password vndnumber:(NSString*)vndnumber {
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:
									   @"https://reportingitc.apple.com/autoingestion.tft?"
									   @"USERNAME=%@"
									   @"&PASSWORD=%@"
									   @"&VNDNUMBER=%@"
									   @"&TYPEOFREPORT=%@"
									   @"&DATETYPE=%@"
									   @"&REPORTTYPE=%@"
									   @"&REPORTDATE=%@",
									   username,
									   password,
									   vndnumber,
									   @"Sales",
									   dateType,
									   @"Summary",
									   dateString, nil]];
	NSError *error = nil;
	NSHTTPURLResponse *response = nil;
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:(NSURLResponse**)&response error:&error];
	
	if (error) {
		NSLog(@"%@", [error localizedDescription]);
		return NO;
	}
	
	NSString *filename =  [[response allHeaderFields] objectForKey:@"filename"];
	
	if (filename) {
		NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"logFileFolderPath"];
		NSString *pathToSave = [path stringByAppendingPathComponent:filename];
		return [data writeToFile:pathToSave atomically:NO];
	}
	return NO;
}

- (void)tryToDownloadReports {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"logFileFolderPath"];
	NSArray *daysToSkip = [ITCDownloader listOfDaysToBeSkippedInAlreadySavedPath:path];
	NSArray *weeksToSkip = [ITCDownloader listOfWeeksToBeSkippedInAlreadySavedPath:path];
	
	NSMutableArray *days = [NSMutableArray arrayWithArray:[ITCDownloader dailyListToBeDownloaded]];
	NSMutableArray *weeks = [NSMutableArray arrayWithArray:[ITCDownloader weeklyListToBeDownloaded]];
	
	[days removeObjectsInArray:daysToSkip];
	[weeks removeObjectsInArray:weeksToSkip];
	
	NSLog(@"-----------------------------------------------");
	
	NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"iTunesConnectUserName"];
	NSString *vndnumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"iTunesConnectVNDNumber"];
	NSString *password = [KeychainAccessor passwordForService:@"iTunesConnectStoreSales" account:username];
	[NSApp activateIgnoringOtherApps:YES];
	
	if ([username length] == 0 || [vndnumber length] == 0 || [password length] == 0) {
		[pool release];
		[self performSelectorOnMainThread:@selector(finishDownloadingReports) withObject:nil waitUntilDone:NO];
		return;
	}
	
	int dailyCount = 0;
	int weeklyCount = 0;
	
	for (NSString *daily in days) {
		NSLog(@"Daily=%@", daily);
		if ([self download:daily dateType:@"Daily" username:username password:password vndnumber:vndnumber])
			dailyCount++;
	}
	for (NSString *weekly in weeks) {
		NSLog(@"Weekly=%@", weekly);
		if ([self download:weekly dateType:@"Weekly" username:username password:password vndnumber:vndnumber])
			weeklyCount++;
	}
	
	[pool release];
	
	NSDictionary *userInfo = [[NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:dailyCount], @"dailyCount",
							  [NSNumber numberWithInt:weeklyCount], @"weeklyCount",
							  nil] retain];
	[self performSelectorOnMainThread:@selector(finishDownloadingReports:) withObject:userInfo waitUntilDone:NO];
}

- (void) finishDownloadingReports:(NSDictionary*)userInfo {
	
	int dailyCount = [[userInfo objectForKey:@"dailyCount"] intValue];
	int weeklyCount = [[userInfo objectForKey:@"weeklyCount"] intValue];
	
	NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Weekly Log %d files,\rDaily Log %d files are downloaded.", nil), weeklyCount, dailyCount];
	
	[self showGrowlMessageWithTitle:NSLocalizedString(@"StoreSales", nil) description:description];
	
	[userInfo release];
	
	[UIAppDelegate.mainMenuController stopAnimation];
	[UIAppDelegate.mainMenuController setEnabled:YES];
	[UIAppDelegate.fileSendController restartBonjourServer];
}

- (void)showGrowlMessageWithTitle:(NSString*)title description:(NSString*)description {
//	[GrowlApplicationBridge notifyWithTitle:title
//								description:description
//						   notificationName:@"SSITCDownloadFinished"
//								   iconData:nil
//								   priority:0
//								   isSticky:NO
//							   clickContext:nil];
}

+ (NSArray*)listOfWeeksToBeSkippedInAlreadySavedPath:(NSString*)path {
	DNSLogMethod
	NSMutableArray *list = [NSMutableArray array];
	
	//
	// Make file list
	//
	BOOL isDir = NO;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *array = [fileManager contentsOfDirectoryAtPath:path error:nil];
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	
	//
	// Date formatter
	//
	// Date format to check list
	NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
	[format setLocale:usLocale];
	[format setDateFormat:@"yyyyMMdd"];
	
	//
	// Make queues
	//
	for (NSString* s in array) {
		NSString *tempPath = [path stringByAppendingPathComponent:s];
		[fileManager fileExistsAtPath:tempPath isDirectory:&isDir];
		if (!isDir) {
			NSData *data = [NSData dataWithContentsOfFile:tempPath];
			ITCLogType type = ITCLogUnknown;
			ITCLogVersion versionType = ITCLogVersion10;
			NSDate *beginDate = nil;
			NSDate *endDate = nil;
			
			if ([ITCLogParser isITCLog:data logType:&type versionType:&versionType beginDate:&beginDate endDate:&endDate]) {
				if (type == ITCLogWeekly) {
					[list addObject:[format stringFromDate:endDate]];
				}
			}
		}
	}
	[usLocale release];
	return [NSArray arrayWithArray:list];
}

+ (NSArray*)listOfDaysToBeSkippedInAlreadySavedPath:(NSString*)path {
	DNSLogMethod
	
	NSMutableArray *list = [NSMutableArray array];
	
	//
	// Make file list
	//
	BOOL isDir = NO;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	
	
	NSArray *array = [fileManager contentsOfDirectoryAtPath:path error:nil];
	
	//
	// Date formatter
	//
	// Date format to check list
	NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
	[format setDateFormat:@"yyyyMMdd"];
	
	//
	// Make queues
	//
	for (NSString* s in array) {
		NSString *tempPath = [path stringByAppendingPathComponent:s];
		[fileManager fileExistsAtPath:tempPath isDirectory:&isDir];
		if (!isDir) {
			NSData *data = [NSData dataWithContentsOfFile:tempPath];
			ITCLogType type = ITCLogUnknown;
			ITCLogVersion versionType = ITCLogVersion10;
			NSDate *beginDate = nil;
			NSDate *endDate = nil;
			
			if ([ITCLogParser isITCLog:data logType:&type versionType:&versionType beginDate:&beginDate endDate:&endDate]) {
				if (type == ITCLogDaily) {
					[list addObject:[format stringFromDate:beginDate]];
				}
			}
		}
	}
	[usLocale release];
	return [NSArray arrayWithArray:list];
}

@end

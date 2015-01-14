//
//  ITCSalesFaces.m
//  StoreSales
//
//  Created by sonson on 10/09/09.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ITCSalesFaces.h"

#import "NSString+substringFromSuffixToPrefix.h"
#import "NSDictionary+HTTP.h"
#import "NSString+ITC.h"
#import "UICNSString+AutoDecoder.h"
#import "SNDownloadManager.h"
#import "ITCTool.h"

#import "ITCDailyStartPageQueue.h"
#import "ITCWeeklyStartPageQueue.h"

#define ITTS_SALES_PAGE_URL @"https://reportingitc.apple.com/sales.faces"

@implementation ITCSalesFaces

+ (ITCSalesFaces*)defaultQueue {
	DNSLogMethod
	ITCSalesFaces *queue = [[ITCSalesFaces alloc] init];
	
#ifdef _USE_COOKIE
	NSMutableArray *cookies = [NSMutableArray array];
	for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
		if ([[cookie domain] rangeOfString:@".apple.com"].location != NSNotFound) {
			[cookies addObject:cookie];
		}
	}
	for (NSHTTPCookie *cookie in cookies) {
		NSLog(@"%@", cookie);
	}
	NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://reportingitc.apple.com/sales.faces"]];
	[request setAllHTTPHeaderFields:headers];
	[queue setRequest:request];
#else
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://reportingitc.apple.com/sales.faces"]];
	[queue setRequest:request];
#endif	
	return [queue autorelease];
}

- (NSString*)extract_j_id_jsp_FromHTML:(NSString*)html {
	NSString *value = nil;
	NSScanner *scanner = [[NSScanner alloc] initWithString:html];
	
	if ([scanner scanUpToString:@"name=\"theForm:j_id_jsp_" intoString:nil]) {
	}
	if ([scanner scanString:@"name=\"" intoString:nil]) {
	}
	if ([scanner scanUpToString:@"_16" intoString:&value]) {
	}
	
	[scanner release];
	
	return value;
}

+ (void)removeWeekFrom:(NSMutableArray*)list alreadySavedIntoPath:(NSString*)path {
	DNSLogMethod
	//
	// Make file list
	//
	BOOL isDir = NO;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *array = [fileManager contentsOfDirectoryAtPath:path error:nil];
	
	//
	// Date formatter
	//
	// Date format to check list
	NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
	[format setDateFormat:@"MM/dd/yyyy"];
	// Date formatter to display for debug
	NSDateFormatter *formatForDebug = [[[NSDateFormatter alloc] init] autorelease];
	[formatForDebug setDateFormat:@"yyyy/MM/dd"];
	
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
					DNSLog(@"Already downloaded weekly data:%@->%@", [formatForDebug stringFromDate:beginDate], [formatForDebug stringFromDate:endDate]);
					//
					// Check endDate is equal to date string included in list, as file name on the pull down menu
					//
					NSString *string_of_endDate = [format stringFromDate:endDate];
					
					for (int i = 0; i < [list count]; i++) {
						NSString *s = [list objectAtIndex:i];
						if ([string_of_endDate isEqualToString:s]) {
							[list removeObjectAtIndex:i];
							break;
						}
					}
				}
			}
		}
	}
}

+ (void)removeDayFrom:(NSMutableArray*)list alreadySavedIntoPath:(NSString*)path {
	DNSLogMethod
	//
	// Make file list
	//
	BOOL isDir = NO;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *array = [fileManager contentsOfDirectoryAtPath:path error:nil];
	
	//
	// Date formatter
	//
	// Date format to check list
	NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
	[format setDateFormat:@"MM/dd/yyyy"];
	// Date formatter to display for debug
	NSDateFormatter *formatForDebug = [[[NSDateFormatter alloc] init] autorelease];
	[formatForDebug setDateFormat:@"yyyy/MM/dd"];
	
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
					//
					// Check endDate is equal to date string included in list, as file name on the pull down menu
					//
					NSString *string_of_endDate = [format stringFromDate:endDate];
					
					for (int i = 0; i < [list count]; i++) {
						NSString *s = [list objectAtIndex:i];
						if ([string_of_endDate isEqualToString:s]) {
							DNSLog(@"Already downloaded daily data:%@->%@", [formatForDebug stringFromDate:beginDate], [formatForDebug stringFromDate:endDate]);
							[list removeObjectAtIndex:i];
							break;
						}
					}
				}
			}
		}
	}
}

- (NSArray*)dailyValuesFromHTML:(NSString*)html {
	NSMutableArray *results = [NSMutableArray array];
	
	NSString *value = [html substringFromSuffix:@"<select id=\"theForm:datePickerSourceSelectElementSales\"" ToPrefix:@"</select>"];
	
	NSScanner *scanner = [[NSScanner alloc] initWithString:value];
	while(![scanner isAtEnd]) {
		NSString *option_value = nil;
		if ([scanner scanUpToString:@"<option value=\"" intoString:nil]) {
			if ([scanner scanString:@"<option value=\"" intoString:nil]) {
				if ([scanner scanUpToString:@"\"" intoString:&option_value]) {
					if ([option_value length]) {
						[results addObject:option_value];
					}
				}
			}
		}
	}
	[scanner release];
	
	return [NSArray arrayWithArray:results];
}

- (NSArray*)weeklyValuesFromHTML:(NSString*)html {
	NSMutableArray *results = [NSMutableArray array];
	
	NSString *value = [html substringFromSuffix:@"<select id=\"theForm:weekPickerSourceSelectElement\"" ToPrefix:@"</select>"];
	
	NSScanner *scanner = [[NSScanner alloc] initWithString:value];
	while(![scanner isAtEnd]) {
		NSString *option_value = nil;
		if ([scanner scanUpToString:@"<option value=\"" intoString:nil]) {
			if ([scanner scanString:@"<option value=\"" intoString:nil]) {
				if ([scanner scanUpToString:@"\"" intoString:&option_value]) {
					if ([option_value length]) {
						[results addObject:option_value];
					}
				}
			}
		}
	}
	[scanner release];
	
	return [NSArray arrayWithArray:results];
}

- (NSData*)dataObtainedWithInfo:(NSDictionary*)postDict response:(NSURLResponse**)returnedResponse {
	NSString *urlString = ITTS_SALES_PAGE_URL;
	NSString *postDictString = [postDict formatForHTTP];
	NSData *httpBody = [postDictString dataUsingEncoding:NSASCIIStringEncoding];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setHTTPBody:httpBody];
	NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:returnedResponse error:NULL];
	return data;
}

#pragma mark -
#pragma mark SNDownloadQueueDelegate

- (void)doTaskAfterDownloadingData:(NSData*)data {
	DNSLogMethod
	NSString *html = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
	DNSLog(@"%@", html);
	
	NSString *nameSuffix = [self extract_j_id_jsp_FromHTML:html];
	
	if ([nameSuffix length] == 0) {
		showAlertWithMessage(NSLocalizedString(@"Failed to access iTunes connect.", nil));
		return;
	}
	
    NSString *dailyName = [nameSuffix stringByAppendingString:@"_6"];
    NSString *weeklyName = [nameSuffix stringByAppendingString:@"_22"];
    NSString *ajaxName = [nameSuffix stringByAppendingString:@"_2"];
    NSString *daySelectName = [nameSuffix stringByAppendingString:@"_43"];
    NSString *weekSelectName = [nameSuffix stringByAppendingString:@"_48"];
	
	DNSLog(@"dailyName=%@", dailyName);
	DNSLog(@"weeklyName=%@", weeklyName);
	DNSLog(@"ajaxName=%@", ajaxName);
	DNSLog(@"daySelectName=%@", daySelectName);
	DNSLog(@"weekSelectName=%@", weekSelectName);
	
	NSMutableArray *dailyValues = [NSMutableArray arrayWithArray:[self dailyValuesFromHTML:html]];
	NSMutableArray *weeklyValues = [NSMutableArray arrayWithArray:[self weeklyValuesFromHTML:html]];
	
	if ([dailyValues count] == 0 || [weeklyValues count] == 0) {
		showAlertWithMessage(NSLocalizedString(@"Failed to access iTunes connect.", nil));
		return;
	}
	
//	DNSLog(@"option daily values-----------------------------------------------------");
//	for (NSString *a in dailyValues) {
//		DNSLog(@" %@", a);
//	}
//	
//	DNSLog(@"option weekly values-----------------------------------------------------");
//	for (NSString *a in weeklyValues) {
//		DNSLog(@" %@", a);
//	}
	
	NSString *dummyDailyValue = [dailyValues objectAtIndex:0];
	NSString *dummyWeeklyValue = [weeklyValues objectAtIndex:0];
	
	NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"logFileFolderPath"];

	[ITCSalesFaces removeDayFrom:dailyValues alreadySavedIntoPath:path];
	[ITCSalesFaces removeWeekFrom:weeklyValues alreadySavedIntoPath:path];
	
	DNSLog(@"option daily values-----------------------------------------------------");
	for (NSString *a in dailyValues) {
		DNSLog(@" %@", a);
	}
	
	DNSLog(@"option weekly values-----------------------------------------------------");
	for (NSString *a in weeklyValues) {
		DNSLog(@" %@", a);
	}

	NSString *viewState = [html extractViewState];
	
	ITCDailyStartPageQueue *queue = [[ITCDailyStartPageQueue alloc] initWithAJAXName:ajaxName
																			   dailyName:dailyName
																			  weeklyName:weeklyName
																		   daySelectName:daySelectName
																		  weekSelectName:weekSelectName
																			 dailyValues:dailyValues
																			weeklyValues:weeklyValues
																			   viewState:viewState
																	 dummyDailyValue:dummyDailyValue
																	dummyWeeklyValue:dummyWeeklyValue];
	[[SNDownloadManager sharedInstance] addQueue:queue];
	[queue release];

	ITCWeeklyStartPageQueue *queue2 = [[ITCWeeklyStartPageQueue alloc] initWithAJAXName:ajaxName
																		   dailyName:dailyName
																		  weeklyName:weeklyName
																	   daySelectName:daySelectName
																	  weekSelectName:weekSelectName
																		 dailyValues:dailyValues
																		weeklyValues:weeklyValues
																			  viewState:viewState
																		dummyDailyValue:dummyDailyValue
																	   dummyWeeklyValue:dummyWeeklyValue];
	[[SNDownloadManager sharedInstance] addToTailQueue:queue2];
	[queue2 release];
}

- (void)doTaskAfterFailedDownload:(NSError*)error {
	DNSLogMethod
	showAlertWithMessage(NSLocalizedString(@"Failed to access Sales Info page.", nil));
}

@end

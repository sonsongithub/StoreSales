//
//  ITCDownloadController.m
//  StoreSales
//
//  Created by sonson on 09/06/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ITCDownloadController.h"

// iTunes connect
#import "ITCProgressWindowController.h"

// Tool
#import "SNDownloadManager.h"

// Qeueu
#import "ITCLoginPage.h"
#import "ITCSQLiteInserter.h"

// SQLite
#import "SQLiteDBController.h"

#import "FileSendController.h"
#import "BonjourController.h"
#import "AppDelegate.h"

NSString* kITCDownloadControllerDownloadCount = @"kITCDownloadControllerDownloadCount";
NSString* kITCDownloadCountKey = @"kITCDownloadCountKey";
NSString* kITCDownloadDailyCountKey = @"kITCDownloadDailyCountKey";
NSString* kITCDownloadWeeklyCountKey = @"kITCDownloadWeeklyCountKey";

@implementation ITCDownloadController

#pragma mark -
#pragma mark Instance method

- (void)startDownloadLog {
	[[windowController window] center];
	[windowController showWindow:nil];
	[UIAppDelegate.mainMenuController startAnimation];
	
	numberOfDailyLogs = 0;
	numberOfWeeklyLogs = 0;
	
	// Extract current existing log files
	[[SQLiteDBController sharedInstance] getRecordLogOfDailyLog:&previousNumberOfDailyLogs weeklyLog:&previousNumberOfWeeklyLogs];
	
	SNDownloadManager *manager = [SNDownloadManager sharedInstance];
	
	ITCLoginPage *queue = [ITCLoginPage defaultQueue];
	[manager addQueue:queue];
	
//	ITCLoginPageDownloadQueue *queue = [ITCLoginPageDownloadQueue defaultQueue];
//	[manager addQueue:queue];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"Progress" object:nil userInfo:nil];
}

- (void)countUp:(NSNotification*)notification {
	// DNSLogMethod
	
	NSDictionary *userInfo = [notification userInfo];
	
	NSString *countKey = [userInfo objectForKey:kITCDownloadCountKey];
	
	if ([countKey isEqualToString:kITCDownloadDailyCountKey]) {
		numberOfDailyLogs++;
	}
	else if ([countKey isEqualToString:kITCDownloadWeeklyCountKey]){
		numberOfWeeklyLogs++;
	}
}

- (void)allDownloadTaskCompleted:(NSNotification*)notification {
	DNSLogMethod
	//
	// Update all application and country flag data
	//
	[windowController close];
	[UIAppDelegate.mainMenuController stopAnimation];
	
	// Update recordLog of SQLite
	[ITCSQLiteInserter insertDownloadedAllFiles];
	
	// Extract current existing log files to confirm how many files have been downloaded.
	// [[SQLiteDBController sharedInstance] getRecordLogOfDailyLog:&numberOfDailyLogs weeklyLog:&numberOfWeeklyLogs];
	
	NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Weekly Log %d files,\rDaily Log %d files are downloaded.", nil), numberOfWeeklyLogs, numberOfDailyLogs];
	
//	[GrowlApplicationBridge notifyWithTitle:NSLocalizedString(@"SSITCDownloadFinished", nil)
//								description:description
//						   notificationName:@"SSITCDownloadFinished"
//								   iconData:nil
//								   priority:0
//								   isSticky:NO
//							   clickContext:nil];
}

- (void)willCancelDownload {
	DNSLogMethod
	SNDownloadManager *manager = [SNDownloadManager sharedInstance];
	[manager removeAllQueue];
	[windowController close];
	[UIAppDelegate.mainMenuController stopAnimation];
}

#pragma mark -
#pragma mark Override

- (id)init {
	self = [super init];
	windowController = [[ITCProgressWindowController defaultController] retain];
	windowController.delegate = self;
	//
	// Set observer, notify after all download queue of DownloadManager
	//
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allDownloadTaskCompleted:) name:kSNDownloadTaskCompleted object:[SNDownloadManager sharedInstance]];
	
	// for counting number of downloaded files
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countUp:) name:kITCDownloadControllerDownloadCount object:nil];
	
	return self;
}

#pragma mark -
#pragma mark dealloc

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[windowController release];
	[super dealloc];
}
	
@end

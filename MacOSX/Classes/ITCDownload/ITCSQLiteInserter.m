//
//  ITCSQLiteInserter.m
//  StoreSales
//
//  Created by sonson on 09/10/12.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ITCSQLiteInserter.h"
#import "ITCLogParser.h"
#import "SQLiteDBController.h"

#import "SNDownloadManager.h"
#import "ITSReviewDownloadQueue.h"
#import "ITSTool.h"
#import "YAHCurrecyCSVDownloadQueue.h"

@implementation ITCSQLiteInserter

+ (void)insertDownloadedAllFiles {
	DNSLogMethod
	
	NSString *logFileFolderPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"logFileFolderPath"];
	NSArray *filepaths = [[NSFileManager defaultManager] subpathsAtPath:logFileFolderPath];
	
	for (NSString *path in filepaths) {
		// DNSLog(@"%@", path);
		NSString *fullpath = [logFileFolderPath stringByAppendingPathComponent:path];
		NSData *data = [NSData dataWithContentsOfFile:fullpath];
		NSDate *beginDate = nil;
		NSDate *endDate = nil;
		ITCLogType type = 0;
		ITCLogVersion version = 0;
		/*ITCDBResult dbResult = */[ITCLogParser insertThisData:data  targetDB:[SQLiteDBController sharedInstance].database beginDate:&beginDate endDate:&endDate logType:&type logVersion:&version];
		// DNSLog(@"ITCDBResult=%d", dbResult);
	}
}

+ (void)updateAppInfoAndCurrencyRate {
	DNSLogMethod
	
	SNDownloadManager *manager = [SNDownloadManager sharedInstance];
	SNDownloadQueue *queue = nil;
	sqlite3 *database = [SQLiteDBController sharedInstance].database;
	
	NSArray *appleIdentifiers = [ITSTool appleIdentifiersFromTargetDatabase:database];
	
	for (NSString *str in appleIdentifiers) {
		DNSLog(@"appleIdentifiers-%@", str);
		queue = [ITSReviewDownloadQueue queueWithAppleIDForApp:[str intValue]];
		[manager addQueue:queue];
	}
	
	queue = [YAHCurrecyCSVDownloadQueue defaultQueue];
	[manager addToTailQueue:queue];
}

@end

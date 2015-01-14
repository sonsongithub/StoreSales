//
//  YAHCurrecyCSVDownloadQueue.m
//  StoreSales
//
//  Created by sonson on 09/05/26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "YAHCurrecyCSVDownloadQueue.h"
#import "UICNSString+AutoDecoder.h"
#import "YAHCurrencyTool.h"
#import "SQLiteDBController.h"

@implementation YAHCurrecyCSVDownloadQueue

+ (YAHCurrecyCSVDownloadQueue*)defaultQueue {
	NSURL *url = [YAHCurrencyTool URLYahooData];
	NSURLRequest *req = [NSURLRequest requestWithURL:url];
	YAHCurrecyCSVDownloadQueue *queue = [[YAHCurrecyCSVDownloadQueue alloc] init];
	queue.request = req;
	return [queue autorelease];
}

@end

#if TARGET_OS_IPHONE
#pragma mark -
#pragma mark for OSX, iPhone

@implementation YAHCurrecyCSVDownloadQueue(OSX_CLIENT)

#pragma mark -
#pragma mark SNDownloadQueueDelegate

- (void)doTaskAfterDownloadingData:(NSData*)data {
	DNSLogMethod
	if (data != nil) {
		NSString *csv = [NSString stringAutoDecodeFromData:data];
		sqlite3 *database = [SQLiteDBController sharedInstance].database;
		[YAHCurrencyTool updateCurrencyTable:csv targetDatabase:database];
	}
}

- (void)doTaskAfterFailedDownload:(NSError*)error {
	DNSLogMethod
#if TARGET_OS_IPHONE | TARGET_IPHONE_SIMULATOR
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
													message:NSLocalizedString(@"Please retry to reload info later.", nil)
												   delegate:nil
										  cancelButtonTitle:nil
										  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
	[alert show];
	[alert release];
#endif
}

@end

#else

#pragma mark -
#pragma mark for MacOSX

@implementation YAHCurrecyCSVDownloadQueue(MacOSX_CLIENT)

#pragma mark -
#pragma mark SNDownloadQueueDelegate

- (void)doTaskAfterDownloadingData:(NSData*)data {
	DNSLogMethod
	if (data != nil) {
		NSString *csv = [NSString stringAutoDecodeFromData:data];
		sqlite3 *database = [SQLiteDBController sharedInstance].database;
		[YAHCurrencyTool updateCurrencyTable:csv targetDatabase:database];
	}
}

@end

#endif
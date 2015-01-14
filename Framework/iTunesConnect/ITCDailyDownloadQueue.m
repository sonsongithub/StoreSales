//
//  ITCDailyDownloadQueue.m
//  StoreSales
//
//  Created by sonson on 10/09/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ITCDailyDownloadQueue.h"
#import "ITCDailyPageQueue.h"
#import "ITCDownloadController.h"

@implementation ITCDailyDownloadQueue

- (void)update {
	
	DNSLogMethod
	NSString *dailyValue = [self.dailyValues objectAtIndex:0];
	NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"theForm",					@"theForm",
							  @"notnormal",					@"theForm:xyz",
							  @"Y",							@"theForm:vendorType",
							  dailyValue,					@"theForm:datePickerSourceSelectElementSales",
							  dummyWeeklyValue,				@"theForm:weekPickerSourceSelectElement",
							  viewState,					@"javax.faces.ViewState",
							  @"theForm:downloadLabel2",	@"theForm:downloadLabel2",
							  nil];
	NSString *urlString = @"https://reportingitc.apple.com/sales.faces";
	NSString *postDictString = [postDict formatForHTTP];
	NSData *httpBody = [postDictString dataUsingEncoding:NSASCIIStringEncoding];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setHTTPBody:httpBody];
	[self setRequest:urlRequest];
}

- (void)doTaskAfterDownloadingData:(NSData*)data {
	[self.dailyValues removeObjectAtIndex:0];
	
	NSString *filename = [[(NSHTTPURLResponse*)self.response allHeaderFields] objectForKey:@"Filename"];
	DNSLog(@"%@", [(NSHTTPURLResponse*)self.response allHeaderFields]);
//	DNSLog(@"%@", [(NSHTTPURLResponse*)self.response allHeaderFields]);
//	DNSLog(@"%d", [data length]);
	DNSLog(@"%@", [NSString stringAutoDecodeFromData:data]);
	
	if ([filename length] > 0) {
		NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"logFileFolderPath"];
		NSString *pathToSave = [path stringByAppendingPathComponent:filename];
		if ([data writeToFile:pathToSave atomically:NO]) {
			// write to file is succeeded.
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:kITCDownloadDailyCountKey forKey:kITCDownloadCountKey];
			[[NSNotificationCenter defaultCenter] postNotificationName:kITCDownloadControllerDownloadCount object:nil userInfo:userInfo];
		}
	}

	// start to download if there are daliy values more than one.
	if ([self.dailyValues count] > 0) {
		ITCDailyPageQueue *queue = [[ITCDailyPageQueue alloc] initWithITCBasicQueue:self];
		[queue setViewState:self.viewState];
		[queue update];
		[[SNDownloadManager sharedInstance] addQueue:queue];
		[queue release];
	}
}

- (void)doTaskAfterFailedDownload:(NSError*)error {
	[self.dailyValues removeObjectAtIndex:0];
}

@end

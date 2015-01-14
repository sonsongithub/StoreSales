//
//  ITCWeeklyDownloadQueue.m
//  StoreSales
//
//  Created by sonson on 10/09/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ITCWeeklyDownloadQueue.h"
#import "ITCWeeklyPageQueue.h"
#import "ITSTool.h"
#import "ITCDownloadController.h"
#import "ITCDailyStartPageQueue.h"

@implementation ITCWeeklyDownloadQueue

- (void)update {
	NSString *weeklyValue = [self.weeklyValues objectAtIndex:0];
	NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"theForm",					@"theForm",
							  @"notnormal",					@"theForm:xyz",
							  @"Y",							@"theForm:vendorType",
							  @"",							@"theForm:datePickerSourceSelectElementSales",
							  weeklyValue,					@"theForm:weekPickerSourceSelectElement",
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
	[self.weeklyValues removeObjectAtIndex:0];
	
	NSString *filename = [[(NSHTTPURLResponse*)self.response allHeaderFields] objectForKey:@"Filename"];
	DNSLog(@"%@", filename);
	
	if ([filename length] > 0) {
		NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"logFileFolderPath"];
		NSString *pathToSave = [path stringByAppendingPathComponent:filename];
		if ([data writeToFile:pathToSave atomically:NO]) {
			// write to file is succeeded.
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:kITCDownloadWeeklyCountKey forKey:kITCDownloadCountKey];
			[[NSNotificationCenter defaultCenter] postNotificationName:kITCDownloadControllerDownloadCount object:nil userInfo:userInfo];
		}
	}
	
	if ([self.weeklyValues count] > 0) {
		ITCWeeklyPageQueue *queue = [[ITCWeeklyPageQueue alloc] initWithITCBasicQueue:self];
		[queue setViewState:self.viewState];
		[queue update];
		[[SNDownloadManager sharedInstance] addQueue:queue];
		[queue release];
	}
	
	if ([[SNDownloadManager sharedInstance].queueStack count] > 1) {
		ITCBasicQueue *nextQueue = [[SNDownloadManager sharedInstance].queueStack objectAtIndex:1];
		
		if ([nextQueue isKindOfClass:[ITCDailyStartPageQueue class]]) {
			[nextQueue setViewState:self.viewState];
		}
	}
}

- (void)doTaskAfterFailedDownload:(NSError*)error {
	[self.weeklyValues removeObjectAtIndex:0];
}

@end

//
//  ITCWeeklyPageQueue.m
//  StoreSales
//
//  Created by sonson on 10/09/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ITCWeeklyPageQueue.h"

#import "ITCWeeklyDownloadQueue.h"

@implementation ITCWeeklyPageQueue

- (void)update {
	DNSLogMethod
	NSString *weeklyValue = [self.weeklyValues objectAtIndex:0];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              ajaxName,				@"AJAXREQUEST",
                              @"theForm",			@"theForm",
                              @"theForm:xyz",		@"notnormal",
                              @"Y",					@"theForm:vendorType",
                              dummyDailyValue,		@"theForm:datePickerSourceSelectElementSales",
                              weeklyValue,			@"theForm:weekPickerSourceSelectElement",
                              viewState,			@"javax.faces.ViewState",
                              weekSelectName,		weekSelectName,
                              nil];	
	
	DNSLog(@"--------------------------------->%@", weeklyValue);
	
	NSString *urlString = @"https://reportingitc.apple.com/sales.faces";
	NSString *postDictString = [postDict formatForHTTP];
	NSData *httpBody = [postDictString dataUsingEncoding:NSASCIIStringEncoding];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setHTTPBody:httpBody];
	[self setRequest:urlRequest];
}

- (void)doTaskAfterDownloadingData:(NSData*)data {
	NSString *html = [NSString stringAutoDecodeFromData:data];
	NSString*newViewState = [html extractViewState];
	
	
	if ([self.weeklyValues count] > 0) {
		ITCWeeklyDownloadQueue *queue = [[ITCWeeklyDownloadQueue alloc] initWithITCBasicQueue:self];
		[queue setViewState:newViewState];
		[queue update];
		[[SNDownloadManager sharedInstance] addQueue:queue];
		[queue release];
	}
}

- (void)doTaskAfterFailedDownload:(NSError*)error {
	[self.weeklyValues removeObjectAtIndex:0];
}

@end

//
//  ITCDailyPageQueue.m
//  StoreSales
//
//  Created by sonson on 10/09/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ITCDailyPageQueue.h"

#import "ITCDailyDownloadQueue.h"
#import "SNDownloadManager.h"

@implementation ITCDailyPageQueue

- (void)update {
	NSString *dailyValue = [self.dailyValues objectAtIndex:0];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              ajaxName,				@"AJAXREQUEST",
                              @"theForm",			@"theForm",
                              @"theForm:xyz",		@"notnormal",
                              @"Y",					@"theForm:vendorType",
                              dailyValue,			@"theForm:datePickerSourceSelectElementSales",
                              dummyWeeklyValue,		@"theForm:weekPickerSourceSelectElement",
                              viewState,			@"javax.faces.ViewState",
                              daySelectName,		daySelectName,
                              nil];	
	
	DNSLog(@"--------------------------------->%@", dailyValue);
	
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
	
//	DNSLog(@"%@", html);
	
	if ([self.dailyValues count] > 0) {
		ITCDailyDownloadQueue *queue = [[ITCDailyDownloadQueue alloc] initWithITCBasicQueue:self];
		[queue setViewState:newViewState];
		[queue update];
		[[SNDownloadManager sharedInstance] addQueue:queue];
		[queue release];
	}
}

- (void)doTaskAfterFailedDownload:(NSError*)error {
	[self.dailyValues removeObjectAtIndex:0];
}

@end

//
//  ITCWeeklyStartPageQueue.m
//  StoreSales
//
//  Created by sonson on 10/09/21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ITCWeeklyStartPageQueue.h"

#import "ITCWeeklyDownloadQueue.h"
#import "ITCWeeklyPageQueue.h"

@implementation ITCWeeklyStartPageQueue

- (ITCWeeklyStartPageQueue*)initWithAJAXName:(NSString*)_ajaxName
								  dailyName:(NSString*)_dailyName
								 weeklyName:(NSString*)_weeklyName
							  daySelectName:(NSString*)_daySelectName
							 weekSelectName:(NSString*)_weekSelectName
								dailyValues:(NSMutableArray*)_dailyValues
							   weeklyValues:(NSMutableArray*)_weeklyValues
								   viewState:(NSString*)_viewState
							 dummyDailyValue:(NSString*)_dummyDailyValue
							dummyWeeklyValue:(NSString*)_dummyWeeklyValue {
	if ((self = [super initWithAJAXName:_ajaxName
							 dailyName:_dailyName
							weeklyName:_weeklyName
						 daySelectName:_daySelectName
						weekSelectName:_weekSelectName
						   dailyValues:_dailyValues
						  weeklyValues:_weeklyValues
							 viewState:_viewState
					   dummyDailyValue:_dummyDailyValue
					  dummyWeeklyValue:_dummyWeeklyValue
				])) {
		
		NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
								   ajaxName,	@"AJAXREQUEST",
								   @"theForm",	@"theForm",
								   @"notnormal",@"theForm:xyz",
								   @"Y",		@"theForm:vendorType",
								   viewState,	@"javax.faces.ViewState",
								   weeklyName,	weeklyName,
								   nil];
		
		NSString *urlString = @"https://reportingitc.apple.com/sales.faces";
		NSString *argumentsString = [arguments formatForHTTP];
		NSData *httpBody = [argumentsString dataUsingEncoding:NSASCIIStringEncoding];
		NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
		[urlRequest setHTTPMethod:@"POST"];
		[urlRequest setHTTPBody:httpBody];
		[self setRequest:urlRequest];
	}
	return self;
}

#pragma mark -
#pragma mark SNDownloadQueueDelegate

- (void)doTaskAfterDownloadingData:(NSData*)data {
	DNSLogMethod
	
	NSString *html = [NSString stringAutoDecodeFromData:data];
	NSString *newViewState = [html extractViewState];
	
	if ([self.weeklyValues count] > 0) {
		ITCWeeklyPageQueue *queue = [[ITCWeeklyPageQueue alloc] initWithITCBasicQueue:self];
		[queue setViewState:newViewState];
		[queue update];
		[[SNDownloadManager sharedInstance] addQueue:queue];
		[queue release];
	}
}

- (void)doTaskAfterFailedDownload:(NSError*)error {
	DNSLogMethod
}

@end

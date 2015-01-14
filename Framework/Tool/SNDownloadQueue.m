//
//  SNDownloadQueue.m
//  StoreSales
//
//  Created by sonson on 09/05/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SNDownloadQueue.h"


@implementation SNDownloadQueue

@synthesize target;
@synthesize url;
@synthesize request;
@synthesize response;
@synthesize selector;
@synthesize result;
@synthesize resultError;

#pragma mark -
#pragma mark 

+ (SNDownloadQueue*)queueFromURL:(NSURL*)URL {
	SNDownloadQueue *queue = [[self alloc] init];
	queue.url = URL;
	return [queue autorelease];
}

+ (SNDownloadQueue*)queueFromURLRequest:(NSURLRequest*)URLRequest {
	SNDownloadQueue *queue = [[self alloc] init];
	queue.request = URLRequest;
	return [queue autorelease];
}

#pragma mark -
#pragma mark 

- (void)doTaskAfterDownloadingData:(NSData*)data {
	DNSLogMethod
	DNSLog(@"URL:%@", [self.url absoluteString]);
	DNSLog(@"Bytes:%d", [data length]);
}

- (void)doTaskAfterFailedDownload:(NSError*)error {
	DNSLogMethod
	DNSLog(@"URL:%@", [self.url absoluteString]);
	DNSLog(@"Error:%@", [error description]);
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[url release];
	[response release];
	[target release];
	[request release];
	[resultError release];
	[super dealloc];
}

@end

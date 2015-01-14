//
//  SNDownloadManager.m
//  StoreSales
//
//  Created by sonson on 09/05/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SNDownloadManager.h"
#import "SNDownloadQueue.h"

SNDownloadManager* sharedSNDownloadManager = nil;

NSString *kSNDownloadTaskCompleted = @"kSNDownloadTaskCompleted";

@implementation SNDownloadManager

@synthesize queueStack;
@synthesize downloader;
@synthesize downloadData;
@synthesize isOnline;

+ (SNDownloadManager*)sharedInstance {
	if (sharedSNDownloadManager == nil) {
		sharedSNDownloadManager = [[SNDownloadManager alloc] init];
	}
	return sharedSNDownloadManager;
}

- (id)init {
	self = [super init];
	self.queueStack = [NSMutableArray array];
	isOnline = YES;
	return self;
}

- (void)removeAllQueue {
	DNSLogMethod
	DNSLog(@"Remove %d queues", [queueStack count]);
	[self.downloader cancel];
	self.downloadData = nil;
	self.downloader = nil;
	[queueStack removeAllObjects];
}

- (void)startDownload {
	DNSLogMethod
	if ([queueStack count] == 0) {
		//
		// All queue have been completed
		//
		[[NSNotificationCenter defaultCenter] postNotificationName:kSNDownloadTaskCompleted object:self userInfo:nil];
		return;
	}
	//
	// Fetch first queue.
	//
	SNDownloadQueue *queue = [queueStack objectAtIndex:0];
	
	//
	// Start to download based on the queue.
	//
	if (queue.request == nil) {
		queue.request = [[[NSMutableURLRequest alloc] initWithURL:queue.url] autorelease];
	}
	self.downloader = [[NSURLConnection alloc] initWithRequest:queue.request delegate:self];
	self.downloadData = [NSMutableData data];
	[self.downloader release];
	
	DNSLog(@"Now starting - %@", [[queue.request URL] absoluteString]);
}

- (void)addQueue:(SNDownloadQueue*)queue {
	if ([queueStack count] > 0) {
		//
		// like FIFO, first in first out
		//
		[queueStack insertObject:queue atIndex:1];
	}
	else {
		//
		// can't insert at index 0 when queue stack is vacant.
		//
		[queueStack addObject:queue];
	}
	//
	// Right now start to download when queue stack is vacant.
	//
	if ([queueStack count] == 1) {
		[self startDownload];
	}
}

- (void)addToTailQueue:(SNDownloadQueue*)queue {
	[queueStack addObject:queue];
	//
	// Right now start to download when queue stack is vacant.
	//
	if ([queueStack count] == 1) {
		[self startDownload];
	}
}

- (void)removeQueuesForTarget:(id)target {
	for (int i = 1; i < [queueStack count]; i++) {
		SNDownloadQueue *queue = [queueStack objectAtIndex:i];
		if (queue.target == target) {
			[queueStack removeObjectAtIndex:i];
		}
	}
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	DNSLogMethod
	SNDownloadQueue *queue = [queueStack objectAtIndex:0];
	queue.response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data lengthReceived:(int)length {
	[self.downloadData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	DNSLogMethod
	SNDownloadQueue *queue = [queueStack objectAtIndex:0];
	if ([queue respondsToSelector:@selector(doTaskAfterDownloadingData:)]) {
		[queue doTaskAfterDownloadingData:self.downloadData];
	}
	[queueStack removeObjectAtIndex:0];
	[self startDownload];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	DNSLogMethod
	SNDownloadQueue *queue = [queueStack objectAtIndex:0];
	if ([queue respondsToSelector:@selector(doTaskAfterFailedDownload:)]) {
		[queue doTaskAfterFailedDownload:error];
	}
	[queueStack removeObjectAtIndex:0];
	[self startDownload];
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[queueStack release];
	[super dealloc];
}

@end
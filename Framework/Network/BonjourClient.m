//
//  BonjourClient.m
//  StoreSales
//
//  Created by sonson on 09/05/14.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BonjourClient.h"

// protocol for NSNetService and NSNetServiceBrowser's delegate methods
@interface NSObject (BonjourClientDelegatePrivate)
- (void)netServiceBrowser:(NSNetServiceBrowser*)aNetServiceBrowser didRemoveService:(NSNetService*)service moreComing:(BOOL)moreComing;
- (void)netServiceBrowser:(NSNetServiceBrowser*)aNetServiceBrowser didFindService:(NSNetService*)service moreComing:(BOOL)moreComing;
- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict;
- (void)netServiceDidResolveAddress:(NSNetService *)service;
@end

@implementation BonjourClient

@synthesize foundServices, netServiceBrowser, currentResolvedService, searchType, searchDomain;

#pragma mark -
#pragma mark Stop

- (void)stop {
	DNSLogMethod
	// stop all client's services
	[self stopCurrentResolvedService];
	[self closeStreams];
	[self stopServiceBrowser];
}

- (void)stopCurrentResolvedService {
	DNSLogMethod
	// stop the service which has been currently resolved
	[self.currentResolvedService stop];
	self.currentResolvedService = nil;
}

- (void)startServiceBrowser {
	DNSLogMethod
	// start to browse Bonjour service
	[self.netServiceBrowser searchForServicesOfType:self.searchType inDomain:self.searchDomain];
	self.netServiceBrowser.delegate = self;
}

- (void)stopServiceBrowser {
	DNSLogMethod
	// stop currenct NetServiceBrowser
	[self.foundServices removeAllObjects];
	[self.netServiceBrowser stop];
	self.netServiceBrowser.delegate = nil;
}

- (void)restartServiceBrowser {
	DNSLogMethod
	// restart to stop currenct NetServiceBrowser
	[self stopServiceBrowser];
	[self startServiceBrowser];
}

- (void)revokeServiceBrowser {
	DNSLogMethod
	// alloc NSNetServiceBrowser after released it.
	self.netServiceBrowser.delegate = nil;
	self.netServiceBrowser = [[[NSNetServiceBrowser alloc] init] autorelease];
	self.netServiceBrowser.delegate = self;
}

#pragma mark -
#pragma mark Try to shake a hand

- (void)tryToResolveNewService:(NSNetService*)service {
	DNSLogMethod
	[self closeStreams];
	[self stopServiceBrowser];
	
	self.currentResolvedService = service;
	[self.currentResolvedService setDelegate:self];
	[self.currentResolvedService resolveWithTimeout:0.0];
}

#pragma mark -
#pragma mark NSNetServiceBrowserDelegate

- (void)netServiceBrowser:(NSNetServiceBrowser*)aNetServiceBrowser didRemoveService:(NSNetService*)service moreComing:(BOOL)moreComing {	
	DNSLogMethod
	[self.foundServices removeObject:service];
	if ([self.delegate respondsToSelector:@selector(netServiceBrowser:didRemoveService:moreComing:)]) {
		[(NSObject*)self.delegate netServiceBrowser:aNetServiceBrowser didRemoveService:service moreComing:moreComing];
	}
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)aNetServiceBrowser didFindService:(NSNetService*)service moreComing:(BOOL)moreComing {
	DNSLogMethod
	[self.foundServices addObject:service];
	if ([self.delegate respondsToSelector:@selector(netServiceBrowser:didFindService:moreComing:)]) {
		[(NSObject*)self.delegate netServiceBrowser:aNetServiceBrowser didFindService:service moreComing:moreComing];
	}
}

#pragma mark -
#pragma mark NSNetServiceDelegate

- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
	DNSLogMethod
	if ([self.delegate respondsToSelector:@selector(netService:didNotResolve:)]) {
		[(NSObject*)self.delegate netService:service didNotResolve:errorDict];
	}
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
	DNSLogMethod
	
	if (service == self.currentResolvedService) {
		NSInputStream *theInputStream = nil;
		NSOutputStream *theOutputStream = nil;
		if ([service getInputStream:&theInputStream outputStream:&theOutputStream]) {
			self.inStream = theInputStream;
			self.inStream.delegate = self;
			[self.inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			[self.inStream open];
			
			self.outStream = theOutputStream;
			self.outStream.delegate = self;
			[self.outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			[self.outStream open];
		}
		[self stopCurrentResolvedService];
	}
	
	if ([self.delegate respondsToSelector:@selector(netServiceDidResolveAddress:)]) {
		[(NSObject*)self.delegate netServiceDidResolveAddress:service];
	}
}

#pragma mark -
#pragma mark Override

- (id)init {
	DNSLogMethod
	self = [super init];
	self.foundServices = [NSMutableArray array];
	self.netServiceBrowser = [[[NSNetServiceBrowser alloc] init] autorelease];
	self.netServiceBrowser.delegate = self;
	
	self.searchType = @"default";
	self.searchDomain = @"local";
	
	return self;
}

#pragma mark -
#pragma mark dealloc

- (void) dealloc {
	DNSLogMethod
	[self stopServiceBrowser];
	[self stopCurrentResolvedService];

	[netServiceBrowser release];
	[currentResolvedService release];
	
	[foundServices release];
	[super dealloc];
}

@end

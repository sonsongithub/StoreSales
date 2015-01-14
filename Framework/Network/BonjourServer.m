//
//  BonjourServer.m
//  StoreSalesClient
//
//  Created by sonson on 09/05/15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BonjourServer.h"

// protocol for NSNetService and NSNetServiceBrowser's delegate methods
@interface NSObject (BonjourServerDelegatePrivate)
- (void)netServiceBrowser:(NSNetServiceBrowser*)aNetServiceBrowser didRemoveService:(NSNetService*)service moreComing:(BOOL)moreComing;
- (void)netServiceBrowser:(NSNetServiceBrowser*)aNetServiceBrowser didFindService:(NSNetService*)service moreComing:(BOOL)moreComing;
- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict;
- (void)netServiceDidResolveAddress:(NSNetService *)service;
@end

NSString* bonjourServerName = nil;

@implementation BonjourServer

@synthesize tcpServer, serviceType, serviceDomain;

#pragma mark -
#pragma mark Class method

+ (NSString*)serverName {
	return bonjourServerName;
}

#pragma mark -
#pragma mark Start/Stop Control

- (void)startServer {
	DNSLogMethod
	NSError* error;
	self.tcpServer = [[[TCPServer alloc] init] autorelease];
	[self.tcpServer setDelegate:self];
	if(self.tcpServer == nil || ![self.tcpServer start:&error]) {
		DNSLog(@"Failed creating server: %@", error);
	}
	if(![self.tcpServer enableBonjourWithDomain:self.serviceDomain applicationProtocol:self.serviceType name:nil]) {
		DNSLog(@"Failed creating server");
	}
}

- (void)stopServer {
	DNSLogMethod
	[self.tcpServer stop];
	self.tcpServer = nil;
}

#pragma mark -
#pragma mark TCPServerDelegate

- (void) serverDidEnableBonjour:(TCPServer*)server withName:(NSString*)string {
	DNSLogMethod
	DNSLog(@"Update server name - %@", string);
	[bonjourServerName release];
	bonjourServerName = [string retain];
}

- (void)didAcceptConnectionForServer:(TCPServer*)aServer inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr {
	DNSLogMethod
	
	if (inStream || outStream || tcpServer != aServer)
		return;
	
	[self stopServer];
	
	self.inStream = istr;
	self.outStream = ostr;
	
	[self openStreams];
}

#pragma mark -
#pragma mark Override

- (id)init {
	self = [super init];
	
	self.serviceDomain = @"local";
	self.serviceType = @"default";
	
	return self;
}

#pragma mark -
#pragma mark Dealloc

- (void) dealloc {
	DNSLogMethod
	[self stopServer];
	[tcpServer release];
	[super dealloc];
}


@end

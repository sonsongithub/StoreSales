//
//  BonjourServer.h
//  StoreSalesClient
//
//  Created by sonson on 09/05/15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPServer.h"
#import "StreamManager.h"

@interface BonjourServer : StreamManager <TCPServerDelegate> {
	TCPServer	*tcpServer;
	NSString	*serviceType;
	NSString	*serviceDomain;
}
@property (nonatomic, retain) TCPServer	*tcpServer;
@property (nonatomic, retain) NSString *serviceType;
@property (nonatomic, retain) NSString *serviceDomain;

#pragma mark -
#pragma mark Class method
+ (NSString*)serverName;
#pragma mark -
#pragma mark Start/Stop Control
- (void)startServer;
- (void)stopServer;

@end

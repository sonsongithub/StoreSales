//
//  BonjourClient.h
//  StoreSales
//
//  Created by sonson on 09/05/14.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StreamManager.h"

@interface BonjourClient : StreamManager
#if TARGET_OS_IPHONE	// a couple of protocols are not implemented on MacOSX
<NSNetServiceDelegate, NSNetServiceBrowserDelegate>
#else
<NSStreamDelegate, NSNetServiceDelegate, NSNetServiceBrowserDelegate>
#endif
{
	NSMutableArray			*foundServices;
	NSNetServiceBrowser		*netServiceBrowser;
	NSNetService			*currentResolvedService;
	
	NSString				*searchType;
	NSString				*searchDomain;
}
@property (nonatomic, retain) NSMutableArray* foundServices;
@property (nonatomic, retain) NSNetServiceBrowser* netServiceBrowser;
@property (nonatomic, retain) NSNetService* currentResolvedService;

@property (nonatomic, retain) NSString *searchType;
@property (nonatomic, retain) NSString *searchDomain;

#pragma mark -
#pragma mark Stop
- (void)stop;
- (void)stopCurrentResolvedService;
- (void)startServiceBrowser;
- (void)stopServiceBrowser;
- (void)restartServiceBrowser;
- (void)revokeServiceBrowser;
#pragma mark -
#pragma mark Try to shake a hand
- (void)tryToResolveNewService:(NSNetService*)service;

@end

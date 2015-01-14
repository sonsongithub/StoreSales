//
//  SyncingController.h
//  StoreSalesClient
//
//  Created by sonson on 09/05/15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BonjourClient.h"

@interface SyncingController : NSObject <UIActionSheetDelegate, StreamManagerDelegate> {
	BOOL			isNeedUpdateCurrencyAndAppInfo;
	BonjourClient	*client;
	BOOL			didFailed;
}
@property (nonatomic, assign) BonjourClient *client;
+ (SyncingController*)defaultController;
#pragma mark -
#pragma mark Class method
+ (SyncingController*)defaultController;
#pragma mark -
#pragma mark init
- (id)initWithDelegate:(id)delegate;
#pragma mark -
#pragma mark XML Maker
- (NSData*)requestStartXML;
- (NSData*)requestXML;
- (NSData*)requestNextXML;
#pragma mark -
#pragma mark Send data
- (void)sendData:(NSData*)data;
- (void)sendRequest;

//
- (BOOL)dispatchData:(NSData*)data stream:(NSStream*)stream;

@end

//
//  FileSendController.h
//  StoreSales
//
//  Created by sonson on 09/06/03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StreamManager.h"
#import "FileSendWindowController.h"

@class BonjourServer;
@class FileSendWindowController;
@class FileSendConfirmSheetController;
@class FileSendQueueController;

typedef enum {
	FileSendControllerPending				= 0,
	FileSendControllerWaitingRequest		= 1,
	FileSendControllerWaitingNextFile		= 2,
}FileSendControllerState;

@interface FileSendController : NSObject <StreamManagerDelegate, FileSendWindowControllerDelegate> {
	FileSendWindowController		*sendWindowController;
	FileSendConfirmSheetController	*confirmSheetController;
	BonjourServer					*server;
	FileSendControllerState			state;
	
	FileSendQueueController			*queueController;
	
	//
	// Status queue data
	//
	int								remained;
	int								already;
	
	// send log file
	int								previousNumberOfSendLogs;
}
@property (nonatomic, retain) BonjourServer *server;
- (BOOL)sendFile;
- (void)sendWithBonjourServerData:(NSData*)data;
- (void)initializeBonjourServer;
- (void)dispatchXML:(NSDictionary*)xmlDictionary;
- (void)openProgressWindow;
- (void)closeProgressWindow;
- (void)openConfirmSheet;
- (void)closeConfirmSheet;
- (void)confirmSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)didPushCancelButton;
- (void)restartBonjourServer;
- (void)pauseBonjourServer;
@end

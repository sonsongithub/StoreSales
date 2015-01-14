//
//  FileSendWindowController.h
//  StoreSales
//
//  Created by sonson on 09/05/15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BonjourServer.h"

extern NSString *kFileSendWindowUpdateProgress;
extern NSString *kFileSendWindowKeyForUpdateMessage;

@class BonjourServer;
@class FileSendConfirmSheetController;

@protocol FileSendWindowControllerDelegate <NSObject>
- (void)didPushCancelButton;
@end

@interface FileSendWindowController : NSWindowController <StreamManagerDelegate> {
	//
	// xib
	//
    IBOutlet NSButton				*cancelButton;
    IBOutlet NSTextField			*description;
    IBOutlet NSProgressIndicator	*indicator;
	
	BOOL							isIndicatorAnimating;
	
	//
	// delegate
	//
	id<FileSendWindowControllerDelegate> delegate;
}
// property
@property (nonatomic, assign) id<FileSendWindowControllerDelegate> delegate;

- (IBAction)pushCancel:(id)sender;
+ (FileSendWindowController*)defaultController;
@end

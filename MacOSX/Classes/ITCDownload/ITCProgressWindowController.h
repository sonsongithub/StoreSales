//
//  ITCProgressWindowController.h
//  StoreSales
//
//  Created by sonson on 09/06/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *kITCUpdateProgress;
extern NSString *kITCKeyForUpdateMessage;

@protocol ITCProgressWindowControllerDelegate <NSObject>
- (void)willCancelDownload;
@end

@interface ITCProgressWindowController : NSWindowController {
    IBOutlet NSButton				*cancelButton;
    IBOutlet NSProgressIndicator	*indicator;
    IBOutlet NSTextField			*description;
	
	//
	BOOL							isIndicatorAnimating;
	id <ITCProgressWindowControllerDelegate> delegate;
}
@property (nonatomic, retain) id<ITCProgressWindowControllerDelegate> delegate;
+ (ITCProgressWindowController*)defaultController;
- (IBAction)pushCancel:(id)sender;
- (void)updateMessage:(NSNotification*)notification;
@end

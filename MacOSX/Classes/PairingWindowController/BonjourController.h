//
//  BonjourController.h
//  StoreSales
//
//  Created by sonson on 09/04/30.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StreamManager.h"

@class BonjourClient;

@interface BonjourController : NSWindowController <StreamManagerDelegate>{
	BonjourClient			*client;
	
	// Interface Builder
	IBOutlet NSButton		*removeButton;
	IBOutlet NSTableView	*tableView;
	
	BOOL					buttonState;
}
@property (nonatomic, retain) BonjourClient* client;

#pragma mark -
#pragma mark Class method
+ (BonjourController*)defaultController;

- (void)reloadUIAutomatically;
- (void)reloadUI:(BOOL)paired;

#pragma mark -
#pragma mark IBAction
- (IBAction)pushCloseButton:(id)sender;
- (IBAction)pushRemoveCurrentDevice:(id)sender;
- (void) doubleClicked:(id)sender;
- (void)passcodeInputSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

@end

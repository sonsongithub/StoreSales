//
//  FileSendConfirmSheetController.h
//  StoreSales
//
//  Created by sonson on 09/05/15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	FileSendConfirmSheetOK		= 0,
	FileSendConfirmSheetCancel	= 1
}FileSendConfirmSheetResult;

@interface FileSendConfirmSheetController : NSWindowController {
	//
	// xib
	//
    IBOutlet NSButton				*checkBox;
    IBOutlet NSTextField			*message;
	
	//
	// delegate
	//
	id								delegate;
}
@property (nonatomic, retain) id delegate;
- (IBAction)pushCancel:(id)sender;
- (IBAction)pushOK:(id)sender;
+ (FileSendConfirmSheetController*)defaultController;
- (void)openAsSheetInWindow:(NSWindow*)targetWindow;
@end

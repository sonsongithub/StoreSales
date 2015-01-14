//
//  PasscodeInputWindowController.h
//  StoreSales
//
//  Created by sonson on 09/05/08.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "StreamManager.h"

@class BonjourClient;

typedef enum {
	PasscodeInputOK = 0,
	PasscodeInputCancel = 1,
	PasscodeInputError = 2
}PasscodeInputSheetResult;

@interface PasscodeInputSheetController : NSWindowController <StreamManagerDelegate> {
	NSMutableArray			*digitImages;
	int						currentDigit;
	NSImageView				*digitImageViews[4];
	unichar					unicharsToSend[4];
	int						digits[4];
	
	BonjourClient			*client;
	
	BOOL					hasAlreadySuccessed;
	
	NSWindow				*parentWindow;

	// for xib
	IBOutlet NSImageView	*digit0;
    IBOutlet NSImageView	*digit1;
    IBOutlet NSImageView	*digit2;
    IBOutlet NSImageView	*digit3;
    IBOutlet NSProgressIndicator *indicator;
    IBOutlet NSTextField	*messageField;
}
@property (nonatomic, retain) BonjourClient* client;
@property (nonatomic, retain) NSWindow* parentWindow;

#pragma mark -
#pragma mark IBAction
- (IBAction)pusuCancelButton:(id)sender;
#pragma mark -
#pragma mark Instance method
- (void)sendData:(NSData*)data;
#pragma mark -
#pragma mark XML Maker
- (NSData*)XMLToSendPasscode;
- (NSData*)XMLToSendSuccessMeesage;
#pragma mark -
#pragma mark Update UI
- (void)setUIPromptForInput;
- (void)setUIPromptForLinking;
- (void)setUIPromptForResult:(BOOL)success;
- (void)setUIPromptForError:(int)errorCode;
#pragma mark -
#pragma mark Reaction dispatcher based on received XML
- (void)checkXML:(NSData*)data;

@end

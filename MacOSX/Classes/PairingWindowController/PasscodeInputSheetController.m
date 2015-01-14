//
//  PasscodeInputWindowController.m
//  StoreSales
//
//  Created by sonson on 09/05/08.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PasscodeInputSheetController.h"
#import "PairingXMLParser.h"
#import "UICNSData+AES256.h"
#import "BonjourClient.h"
#import "BonjourServer.h"
#import "FileSendWindowController.h"
#import "MainMenuController.h"

@implementation PasscodeInputSheetController

@synthesize parentWindow, client;

#pragma mark -
#pragma mark IBAciton

- (IBAction)pusuCancelButton:(id)sender {
    DNSLogMethod
	[NSApp endSheet:[self window] returnCode:PasscodeInputCancel];
	[self close];
}

#pragma mark -
#pragma mark Instance method

- (void)sendData:(NSData*)data {
	NSData *encryptedData = [data dataEncryptedWithKey:@"d38jslajd8d"];
	[client sendData:encryptedData];
}

#pragma mark -
#pragma mark XML Maker

- (NSData*)XMLToSendPasscode {
	NSMutableString *xml = [NSMutableString string];
	[xml appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
	[xml appendString:@"<StoreSalesPairing>"];
	[xml appendFormat:@"<macname>%@</macname>", [BonjourServer serverName]];
	[xml appendFormat:@"<challenge>%d%d%d%d</challenge>", digits[0], digits[1], digits[2], digits[3]];
	[xml appendString:@"</StoreSalesPairing>"];
	return [xml dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData*)XMLToSendSuccessMeesage {
	NSMutableString *xml = [NSMutableString string];
	[xml appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
	[xml appendString:@"<StoreSalesPairing>"];
	[xml appendFormat:@"<pairingResult>success</pairingResult>"];
	[xml appendString:@"</StoreSalesPairing>"];
	return [xml dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark -
#pragma mark Update UI

- (void)setUIPromptForInput {
	[indicator setHidden:YES];
	[indicator stopAnimation:self];
	[messageField setStringValue:NSLocalizedString(@"Input passcode showed by iPhone.", nil)];
}

- (void)setUIPromptForLinking {
	[indicator setHidden:NO];
	[indicator startAnimation:self];
	[messageField setStringValue:NSLocalizedString(@"Linking...", nil)];
}

- (void)setUIPromptForResult:(BOOL)success {
	[indicator setHidden:NO];
	[indicator startAnimation:self];
	if (success) {
		[messageField setStringValue:NSLocalizedString(@"Pairing is completed.", nil)];
	}
	else {
		[messageField setStringValue:NSLocalizedString(@"Failed...", nil)];
	}
}

- (void)setUIPromptForError:(int)errorCode {
	[indicator setHidden:YES];
	[indicator stopAnimation:self];
	if (errorCode == 1) {
		[messageField setStringValue:NSLocalizedString(@"Passcode is wrong, please input passcode again.", nil)];
	}
	else if (errorCode == 2) {
		[messageField setStringValue:NSLocalizedString(@"Unknown error, please input passcode again.", nil)];
	}
	else {
		[messageField setStringValue:NSLocalizedString(@"Unknown error, please input passcode again.", nil)];
	}
}

#pragma mark -
#pragma mark Reaction dispatcher based on received XML

- (void)checkXML:(NSData*)data {
	NSData *decryptedData = [data dataDecryptedWithKey:@"d38jslajd8d"];
	PairingXMLParser* parser = [[PairingXMLParser alloc] init];
	[parser parse:decryptedData];
	[parser dump];
	
	if ([parser.dictionary objectForKey:@"error"] ) {
		// error
		for (int i = 0; i < 4; i++)
			[digitImageViews[i] setImage:nil];
		currentDigit = 0;
		[self setUIPromptForError:[[parser.dictionary objectForKey:@"error"] intValue]];
	}
	else if ([parser.dictionary objectForKey:@"udid"] && [parser.dictionary objectForKey:@"iphone"]) {
		NSString *udid = [parser.dictionary objectForKey:@"udid"];
		NSString *iphone = [parser.dictionary objectForKey:@"iphone"];
		NSString *passcode = [NSString stringWithFormat:@"%d%d%d%d", digits[0], digits[1], digits[2], digits[3]];

		//NSData *data = [self XMLToSendSuccessMeesage];
		//[self sendData:data];
		hasAlreadySuccessed = YES;
		
		[UIAppDelegate updatePairedDeviceWithName:iphone UDID:udid passcode:passcode];
		[UIAppDelegate.mainMenuController reloadMenuItemAboutPairedDevice];
		
		[NSApp endSheet:[self window] returnCode:PasscodeInputCancel];
		[self close];
	}

	[parser release];
}


#pragma mark -
#pragma mark StreamManagerDelegate

- (void)openCompletedStream:(NSStream*)stream {
}

- (void)endEncounteredStream:(NSStream*)stream {
	DNSLogMethod
	if (hasAlreadySuccessed) {
		[NSApp endSheet:[self window] returnCode:PasscodeInputOK];
	}
	else {
		[NSApp endSheet:[self window] returnCode:PasscodeInputCancel];
	}
	[[self window] close];
}

- (void)receivedData:(NSData*)data stream:(NSStream*)stream {
	DNSLogMethod
	[self checkXML:data];
}

#pragma mark -
#pragma mark Override

- (id) init {
	self = [super initWithWindowNibName:@"PasscodeInputSheet"];
	if (self) {
		digitImages = [[NSMutableArray array] retain];
		[digitImages addObject:[NSImage imageNamed:@"pc0.png"]];
		[digitImages addObject:[NSImage imageNamed:@"pc1.png"]];
		[digitImages addObject:[NSImage imageNamed:@"pc2.png"]];
		[digitImages addObject:[NSImage imageNamed:@"pc3.png"]];
		[digitImages addObject:[NSImage imageNamed:@"pc4.png"]];
		[digitImages addObject:[NSImage imageNamed:@"pc5.png"]];
		[digitImages addObject:[NSImage imageNamed:@"pc6.png"]];
		[digitImages addObject:[NSImage imageNamed:@"pc7.png"]];
		[digitImages addObject:[NSImage imageNamed:@"pc8.png"]];
		[digitImages addObject:[NSImage imageNamed:@"pc9.png"]];
		currentDigit = 0;
	}
	return self;
}

- (void) awakeFromNib {
	DNSLogMethod
	[[self window] makeFirstResponder:self];
	
	digitImageViews[0] = digit0;
	digitImageViews[1] = digit1;
	digitImageViews[2] = digit2;
	digitImageViews[3] = digit3;
	
	[self setUIPromptForInput];
}

- (BOOL) acceptFirstResponder {
    return YES;
}

- (void) keyDown:(NSEvent*)event {
	NSString* keys=[event charactersIgnoringModifiers];
	if ([keys length] == 1) {
		unichar u = [keys characterAtIndex:0];
		if (u >= 48 && u <= 57) {
			if (currentDigit < 4) {
				hasAlreadySuccessed = NO;
				int digitNum = u - 48;
				digits[currentDigit] = digitNum;
				[digitImageViews[currentDigit++] setImage:[digitImages objectAtIndex:digitNum]];
				DNSLog(@"%@ = %d", keys, [keys characterAtIndex:0]);
				if (currentDigit == 4) {
					[self setUIPromptForLinking];
					NSData *data = [self XMLToSendPasscode];
					[self sendData:data];
				}
			}
		}
	}
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	DNSLogMethod
	[client release];
	[parentWindow release];
	[digitImages release];
	[super dealloc];
}

@end

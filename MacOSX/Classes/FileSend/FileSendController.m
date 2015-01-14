//
//  FileSendController.m
//  StoreSales
//
//  Created by sonson on 09/06/03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FileSendController.h"

// Network
#import "BonjourServer.h"

// Tool
#import "UICNSData+AES256.h"

// iTunes connect
#import "ITCLogParser.h"

// UI
#import "FileSendWindowController.h"
#import "FileSendConfirmSheetController.h"

// XML for communication with Mac
#import "FileSendXMLMaker.h"
#import "PairingXMLParser.h"

// Other controller
#import "MainMenuController.h"
#import "FileSendQueueController.h"
#import "SQLiteDBController.h"

@implementation FileSendController

@synthesize server;

- (BOOL)sendFile {
	NSData *dataToSend = [queueController popQueue];
	if (dataToSend != nil) {
		[self sendWithBonjourServerData:dataToSend];
		return YES;
	}
	return NO;
}

- (void)sendWithBonjourServerData:(NSData*)data {
	DNSLogMethod
	NSString *key = [[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"];
	NSData *encryptedData = [data dataEncryptedWithKey:key];
	[self.server sendData:encryptedData];
}

- (void)initializeBonjourServer {
	[self restartBonjourServer];
}

- (void)restartBonjourServer {
	[self.server closeStreams];
	[self.server startServer];
}

- (void)pauseBonjourServer {
	[self.server stopServer];
	[self.server closeStreams];
}

#pragma mark -
#pragma mark Event dispatcher

- (void)startCommunicate {
	NSData *data = [FileSendXMLMaker XMLToSendRequestOK];
	[self sendWithBonjourServerData:data];
}

- (void)dispatchXML:(NSDictionary*)xmlDictionary {
	DNSLogMethod
	NSString *statusCode = [xmlDictionary objectForKey:@"status"];
	
	DNSLog(@"statusCode=%@", statusCode);
	if ([statusCode isEqualToString:@"requestCheck"]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"WarnWhenRequesting"]) {
			[self performSelector:@selector(startCommunicate) withObject:nil afterDelay:1];
		}
		else {
			[self openConfirmSheet];
		}
	}
	else if ([statusCode isEqualToString:@"requestStart"]) {
		[queueController release];
		queueController = [[FileSendQueueController alloc] init];
		if (![self sendFile]) {
			//
			// There are no files to send
			//
			[self sendWithBonjourServerData:[FileSendXMLMaker XMLToSendTaskFinished]];
		}
	}
	else if ([statusCode isEqualToString:@"request"]) {
		//
		// Update Send log
		//
		updateSendLog(xmlDictionary);
		if (![self sendFile]) {
			//
			// There are no longer files to send
			//
			[self sendWithBonjourServerData:[FileSendXMLMaker XMLToSendTaskFinished]];
		}
	}
}

#pragma mark -
#pragma mark Window

- (void)openProgressWindow {
	//
	// Show window which shows progress about file sending
	//
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[sendWindowController showWindow:nil];
	[[sendWindowController window] center];
	[[sendWindowController window] orderFront:nil];
	
	[UIAppDelegate.mainMenuController setEnabledMenuItems:NO];
	[UIAppDelegate.mainMenuController startAnimation];
	
	// Enabled barmenu while sync
	[UIAppDelegate.mainMenuController setEnabled:NO];
	
	// Confirm existing send log files
	previousNumberOfSendLogs = [[SQLiteDBController sharedInstance] getSendLog];
}

- (void)closeProgressWindow {
	//
	// Close window which shows progress about file sending
	//
	[self closeConfirmSheet];
	[sendWindowController close];
	[UIAppDelegate.mainMenuController setEnabledMenuItems:YES];
	[UIAppDelegate.mainMenuController stopAnimation];
	
	// Confirm current send log files
	int numberOfSendLogs = [[SQLiteDBController sharedInstance] getSendLog];

	NSString *description = [NSString stringWithFormat:NSLocalizedString(@"%d files has been sent.", nil), (numberOfSendLogs - previousNumberOfSendLogs)];
	
//	[GrowlApplicationBridge notifyWithTitle:NSLocalizedString(@"SSiPhoneSyncFinished", nil)
//								description:description
//						   notificationName:@"SSiPhoneSyncFinished"
//								   iconData:nil
//								   priority:0
//								   isSticky:NO
//							   clickContext:nil];
	
	// Enabled barmenu after sync
	[UIAppDelegate.mainMenuController setEnabled:YES];
}

- (void)openConfirmSheet {
	[confirmSheetController openAsSheetInWindow:[sendWindowController window]];
}

- (void)closeConfirmSheet {
	[confirmSheetController pushCancel:nil];
}

#pragma mark -
#pragma mark Sheet Delegate, IBAction

- (void)confirmSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	DNSLogMethod
	DNSLog(@"returnCode=%d", returnCode);
	if (returnCode == FileSendConfirmSheetOK) {
		NSData *data = [FileSendXMLMaker XMLToSendRequestOK];
		[self sendWithBonjourServerData:data];
	}
	if (returnCode == FileSendConfirmSheetCancel) {
		[self initializeBonjourServer];
		[self closeProgressWindow];
	}
}

- (void)didPushCancelButton {
	DNSLogMethod
	[self initializeBonjourServer];
	[self closeProgressWindow];
}

#pragma mark -
#pragma mark StreamManagerDelegate

- (void)openCompletedStream:(NSStream*)stream {
	DNSLogMethod
	[self openProgressWindow];
}

- (void)receivedData:(NSData*)data stream:(NSStream*)stream {
	DNSLogMethod
	//
	// Decrypt and parse received binary data
	//
	NSString *key = [[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"];
	NSString *iphone = [[NSUserDefaults standardUserDefaults] objectForKey:@"iphone"];
	NSString *udid = [[NSUserDefaults standardUserDefaults] objectForKey:@"udid"];
	NSData *decryptedData = [data dataDecryptedWithKey:key];
	
	if (decryptedData == nil) {
		//
		// Failed to decrypt incoming data
		//
		NSAlert* alert =[
						 NSAlert alertWithMessageText:NSLocalizedString(@"Error", nil)
						 defaultButton:NSLocalizedString(@"OK", nil)
						 alternateButton:nil
						 otherButton:nil
						 informativeTextWithFormat:NSLocalizedString(@"Authorization failed.", nil)];
		[alert runModal];
		[self initializeBonjourServer];
		[self closeProgressWindow];
		return;
	}
	if (![iphone length] || ![udid length]) {
		//
		// No device is paired with this mac.
		//
		NSAlert* alert =[NSAlert alertWithMessageText:NSLocalizedString(@"Error", nil)
						 defaultButton:NSLocalizedString(@"OK", nil)
						 alternateButton:nil
						 otherButton:nil
						 informativeTextWithFormat:NSLocalizedString(@"Uknown device sent request or data.", nil)];
		[alert runModal];
		[self initializeBonjourServer];
		[self closeProgressWindow];
		return;
	}
	
	// Parse XML
	PairingXMLParser* parser = [[[PairingXMLParser alloc] init] autorelease];
	[parser parse:decryptedData];
	NSDictionary* receivedXML = parser.dictionary;
	
	// Dispatch
	[self dispatchXML:receivedXML];
}

- (void)endEncounteredStream:(NSStream*)stream {
	DNSLogMethod
	[self initializeBonjourServer];
	[confirmSheetController close];
	[self closeProgressWindow];
}

#pragma mark -
#pragma mark Override

- (id)init {
	self = [super init];
	
	//
	// Set up server
	//
	self.server = [[[BonjourServer alloc] init] autorelease];
	self.server.delegate = self;
	self.server.serviceType = [NSString stringWithFormat:@"_%@._tcp.", @"StoreSales"];
	[self.server startServer];
	
	//
	// Setup window controllers
	//
	sendWindowController = [[FileSendWindowController defaultController] retain];
	sendWindowController.delegate = self;
	confirmSheetController = [[FileSendConfirmSheetController defaultController] retain];
	confirmSheetController.delegate = self;
	return self;
}

- (void) dealloc {
	//
	// Release server
	//
	[self.server stopServer];
	[self.server closeStreams];
	[server release];
	
	// Release window controllers
	[sendWindowController release];
	[confirmSheetController release];
	
	// Queue controller
	[queueController release];
	
	[super dealloc];
}


@end

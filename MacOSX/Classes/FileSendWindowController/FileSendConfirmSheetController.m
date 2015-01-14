//
//  FileSendConfirmSheetController.m
//  StoreSales
//
//  Created by sonson on 09/05/15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FileSendConfirmSheetController.h"
#import "PreferencesWindowController.h"

@implementation FileSendConfirmSheetController

@synthesize delegate;

#pragma mark -
#pragma mark Class method

+ (FileSendConfirmSheetController*)defaultController {
	FileSendConfirmSheetController *obj = [[FileSendConfirmSheetController alloc] init];
	return [obj autorelease];
}

#pragma mark -
#pragma mark Method

- (void)openAsSheetInWindow:(NSWindow*)targetWindow {
	DNSLogMethod
	NSString *device_name = [[NSUserDefaults standardUserDefaults] objectForKey:@"iphone"];
	NSString *messageStr = [NSString stringWithFormat:NSLocalizedString(@"\"%@\" is requesting to be sent AppStore sales files to.", nil), device_name];
	[message setStringValue:messageStr];
	
	NSCellStateValue value = ButtonStateFromWarnWhenRequesting([[NSUserDefaults standardUserDefaults] boolForKey:@"WarnWhenRequesting"]);
	[checkBox setState:value];
	
	[NSApp beginSheet:[self window]
	   modalForWindow:targetWindow
		modalDelegate:delegate
	   didEndSelector:@selector(confirmSheetDidEnd:returnCode:contextInfo:)
		  contextInfo:nil];
}

#pragma mark -
#pragma mark IBAction

- (IBAction)pushOK:(id)sender {
	BOOL WarnWhenRequesting = WarnWhenRequestingFromButtonState([checkBox state]);
	[[NSUserDefaults standardUserDefaults] setBool:WarnWhenRequesting forKey:@"WarnWhenRequesting"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[NSApp endSheet:[self window] returnCode:FileSendConfirmSheetOK];
	[self close];
}

- (IBAction)pushCancel:(id)sender {
	DNSLogMethod
	[NSApp endSheet:[self window] returnCode:FileSendConfirmSheetCancel];
	[self close];
}

#pragma mark -
#pragma mark WindowController delegate

- (BOOL)windowShouldClose:(id)window {
	DNSLogMethod
	return YES;
}

- (void)windowDidLoad {
	DNSLogMethod
}

#pragma mark -
#pragma mark Override

- (void)awakeFromNib {
	NSString *device_name = [[NSUserDefaults standardUserDefaults] objectForKey:@"iphone"];
	NSString *messageStr = [NSString stringWithFormat:NSLocalizedString(@"\"%@\" is requesting to be sent AppStore sales files to.", nil), device_name];
	[message setStringValue:messageStr];
}

- (id) init {
	self = [super initWithWindowNibName:@"FileSendConfirmSheetController"];
	if (self) {
	}
	return self;
}

- (void)dealloc {
	DNSLogMethod
	[delegate release];
	[super dealloc];
}

@end

//
//  ITCProgressWindowController.m
//  StoreSales
//
//  Created by sonson on 09/06/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ITCProgressWindowController.h"

NSString *kITCUpdateProgress = @"kITCUpdateProgress";
NSString *kITCKeyForUpdateMessage = @"kITCKeyForUpdateMessage";

@implementation ITCProgressWindowController

@synthesize delegate;

#pragma mark -
#pragma mark Class method

+ (ITCProgressWindowController*)defaultController {
	ITCProgressWindowController *obj = [[ITCProgressWindowController alloc] init];
	return [obj autorelease];
}

#pragma mark -
#pragma mark IBAction or instance method

- (IBAction)pushCancel:(id)sender {
	DNSLogMethod
	if ([delegate respondsToSelector:@selector(willCancelDownload)]) {
		[delegate willCancelDownload];
	}
}

- (void)updateMessage:(NSNotification*)notification {
	DNSLogMethod
	NSDictionary *userInfo = [notification userInfo];
	[description setStringValue:[userInfo objectForKey:kITCKeyForUpdateMessage]];
}

#pragma mark -
#pragma mark Override, Window Controller

- (void)showWindow:(id)sender {
	DNSLogMethod
	[super showWindow:sender];
	[description setStringValue:NSLocalizedString(@"Connecting iTunes connect...", nil)];
	
	if (!isIndicatorAnimating) {
		[indicator startAnimation:nil];
		[indicator setIndeterminate:YES];
		isIndicatorAnimating = YES;
	}
}

#pragma mark -
#pragma mark Override

- (void)close {
	[super close];
	
	// Enabled barmenu after task has been finished
	[UIAppDelegate.mainMenuController setEnabled:YES];
}

- (id)init {
	DNSLogMethod
	if ((self = [super initWithWindowNibName:@"ITCProgressWindowController"])) {
		DNSLogMethod
		isIndicatorAnimating = NO;
		[indicator startAnimation:self];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessage:) name:kITCUpdateProgress object:nil];
	}
	return self;
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	DNSLogMethod
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[delegate release];
	[super dealloc];
}

@end

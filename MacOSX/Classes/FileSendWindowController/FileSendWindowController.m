//
//  FileSendWindowController.m
//  StoreSales
//
//  Created by sonson on 09/05/15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FileSendWindowController.h"

NSString *kFileSendWindowUpdateProgress = @"kFileSendWindowUpdateProgress";
NSString *kFileSendWindowKeyForUpdateMessage = @"kFileSendWindowKeyForUpdateMessage";

@implementation FileSendWindowController

@synthesize delegate;

#pragma mark -
#pragma mark Class method

+ (FileSendWindowController*)defaultController {
	FileSendWindowController *obj = [[FileSendWindowController alloc] init];
	return [obj autorelease];
}

#pragma mark -
#pragma mark IBAction

- (IBAction)pushCancel:(id)sender {
	DNSLogMethod
	NSLog(@"a");
	if ([delegate respondsToSelector:@selector(didPushCancelButton)]) {
		[delegate didPushCancelButton];
	}
}

#pragma mark -
#pragma mark Override, Window Controller

- (void)showWindow:(id)sender {
	DNSLogMethod
	[super showWindow:sender];
	[description setStringValue:NSLocalizedString(@"Connecting...", nil)];
	
	if (!isIndicatorAnimating) {
		[indicator startAnimation:nil];
		[indicator setIndeterminate:YES];
		isIndicatorAnimating = YES;
	}
}

- (BOOL)windowShouldClose:(id)window {
	DNSLogMethod
	
	if (isIndicatorAnimating) {
		[indicator stopAnimation:nil];
		[indicator setIndeterminate:NO];
		isIndicatorAnimating = NO;
	}
	return YES;
}

#pragma mark -
#pragma mark Override

- (void)updateMessage:(NSNotification*)notification {
	DNSLogMethod
	NSDictionary *userInfo = [notification userInfo];
	[description setStringValue:[userInfo objectForKey:kFileSendWindowKeyForUpdateMessage]];
}

- (id)init {
	DNSLogMethod
	self = [super initWithWindowNibName:@"FileSendWindowController"];
	if (self) {
		isIndicatorAnimating = NO;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessage:) name:kFileSendWindowUpdateProgress object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}


@end

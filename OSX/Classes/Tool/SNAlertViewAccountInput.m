//
//  SNAlertViewAccountInput.m
//  alertView
//
//  Created by sonson on 09/04/06.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SNAlertViewAccountInput.h"


@implementation SNAlertViewAccountInput

@synthesize usernameField;
@synthesize passwordField;

- (id)initWithTitle:(NSString*)title delegate:(id)aDelegate {
	if (self = [super initWithTitle:title message:@"\r\r\r" delegate:aDelegate cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil]) {
		[self setTransform:CGAffineTransformMakeTranslation(0, 100)];
		
		self.usernameField = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
		self.usernameField.borderStyle = UITextBorderStyleRoundedRect;
		self.usernameField.backgroundColor = [UIColor clearColor];
		self.usernameField.autocapitalizationType = NO;
		[self addSubview:self.usernameField];
		[self.usernameField release];
		
		self.passwordField = [[UITextField alloc] initWithFrame:CGRectMake(12, 80, 260, 25)];
		self.passwordField.borderStyle = UITextBorderStyleRoundedRect;
		self.passwordField.backgroundColor = [UIColor clearColor];
		[self addSubview:self.passwordField];
		[self.passwordField release];
		
		NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
		[nc addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
	}
	return self;
}


- (void)layoutSubviews {
	DNSLogMethod
	DNSLog(@"Origin %f,%f", self.frame.origin.x, self.frame.origin.y);
	DNSLog(@"Size %f,%f", self.frame.size.width, self.frame.size.height);
}

- (void)applicationDidBecomeActive:(NSNotification*)note {
	[self.usernameField becomeFirstResponder];
}

- (void)applicationWillResignActive:(NSNotification*)note {
	[self.usernameField resignFirstResponder];
}

- (void)show {
	[super show];
	[self.usernameField becomeFirstResponder];
}

- (void)dealloc {
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	[usernameField release];
	[passwordField release];
	[super dealloc];
}

@end

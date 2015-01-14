//
//  LicenseViewController.m
//  StoreSales
//
//  Created by sonson on 10/09/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LicenseViewController.h"


@implementation LicenseViewController

- (id)init {
	DNSLogMethod
	if ((self = [super initWithWindowNibName:@"LicenseViewController"])) {
		DNSLogMethod
	}
	return self;
}

- (void)windowWillClose:(NSNotification *)notification {
	DNSLogMethod
	// Enabled barmenu after closing choose folder sheet
	[UIAppDelegate.mainMenuController setEnabled:YES];
	[self autorelease];
}

- (void)windowDidLoad {
	DNSLogMethod
	[super windowDidLoad];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"license.txt" ofType:nil];
	NSString *licenseString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	
	[textView setEditable:NO];
	[textView setString:licenseString];
}

- (void) dealloc {
	DNSLogMethod
	[super dealloc];
}


@end

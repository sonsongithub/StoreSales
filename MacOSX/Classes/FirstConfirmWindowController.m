//
//  FirstConfirmWindowController.m
//  StoreSales
//
//  Created by sonson on 09/10/06.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FirstConfirmWindowController.h"


@implementation FirstConfirmWindowController

+ (FirstConfirmWindowController*)defaultController {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowFirstConfirmWindow"])
		return nil;
	FirstConfirmWindowController *obj = [[FirstConfirmWindowController alloc] init];
	return [obj autorelease];
}

- (void)show {
	[[self window] center];
	[NSApp runModalForWindow:[self window]];
}

- (id)init {
	DNSLogMethod
	if ((self = [super initWithWindowNibName:@"FirstConfirmWindowController"])) {
	}
	return self;
}

- (IBAction)pusuOKButton:(id)sender {
	DNSLog(@"%d", [checkButton state]);
	[[NSUserDefaults standardUserDefaults] setBool:[checkButton state] forKey:@"ShowFirstConfirmWindow"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[[self window] close];
	[NSApp stopModal];
}

@end

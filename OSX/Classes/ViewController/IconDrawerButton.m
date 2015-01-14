//
//  IconDrawerButton.m
//  StoreSales
//
//  Created by sonson on 09/03/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "IconDrawerButton.h"

@implementation IconDrawerButton

+ (IconDrawerButton*) button {
	IconDrawerButton* button = [IconDrawerButton buttonWithType:UIButtonTypeCustom];
	[button setTitleColor:[UIColor colorWithRed:76.0/255.0f green:86.0/255.0f blue:108.0/255.0f alpha:1.0] forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	button.titleLabel.shadowOffset = CGSizeMake(0, 1);
	[button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitle:NSLocalizedString(@"Flag icons, provied by icondrawer.com", nil) forState:UIControlStateNormal];
	[button addTarget:button action:@selector(clicked:) forControlEvents:UIControlEventTouchDown];
	button.frame = CGRectMake(0,0,320,66);
	return button;
}

- (void)clicked:(id)sender {
	DNSLogMethod
	UIAlertView *view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Flag icon", nil)
												   message:NSLocalizedString(@"about.www.icondrawer.com", nil)
												  delegate:self
										 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
										 otherButtonTitles:NSLocalizedString(@"Open Safari", nil), nil];
	[view show];
	[view release];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	DNSLog(@"buttonIndex = %d", buttonIndex);
	if (buttonIndex == 1) {
		DNSLog(@"OK");
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.icondrawer.com/"]];
	}
	else if (buttonIndex == 0) {
		DNSLog(@"Cancel");
	}
}

@end

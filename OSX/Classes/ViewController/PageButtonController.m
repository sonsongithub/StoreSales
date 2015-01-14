//
//  PageButtonController.m
//  StoreSales
//
//  Created by sonson on 09/10/07.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PageButtonController.h"

@implementation PageButtonController

@synthesize segmentControl;

- (id)initWithDelegate:(id<PageButtonControllerDelegate>)theDelegate {
	if (self = [super init]) {
		NSArray *items = [NSArray arrayWithObjects:[UIImage imageNamed:@"upPageArrow.png"], [UIImage imageNamed:@"downPageArrow.png"], nil];
		segmentControl = [[UISegmentedControl alloc] initWithItems:items];
		segmentControl.momentary = YES;
		segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
		[segmentControl addTarget:self
						   action:@selector(action:)
				 forControlEvents:UIControlEventValueChanged];
		CGRect frame = segmentControl.frame;
		frame.size.width = 90;
		segmentControl.frame = frame;
		delegate = theDelegate;
	}
	return self;
}

- (void)action:(id)sender {
	DNSLogMethod
	if (sender == segmentControl) {
		if (segmentControl.selectedSegmentIndex == 0) {
			if ([delegate respondsToSelector:@selector(didPageUp:)]) {
				[delegate didPageUp:self];
			}
		}
		else if (segmentControl.selectedSegmentIndex == 1) {
			if ([delegate respondsToSelector:@selector(didPageDown:)]) {
				[delegate didPageDown:self];
			}
		}
	}
}

- (void)updateState:(int)current max:(int)max {
	if (current == 0)
		[self upButtonEnabled:NO];
	else 
		[self upButtonEnabled:YES];
	if (current == max)
		[self downButtonEnabled:NO];
	else 
		[self downButtonEnabled:YES];
}

- (void)upButtonEnabled:(BOOL)value {
	[segmentControl setEnabled:value forSegmentAtIndex:0];
}

- (void)downButtonEnabled:(BOOL)value {
	[segmentControl setEnabled:value forSegmentAtIndex:1];
}

- (void) dealloc {
	[segmentControl release];
	[super dealloc];
}

@end

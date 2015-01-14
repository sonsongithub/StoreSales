//
//  AllApplicationViewController.m
//  StoreSales
//
//  Created by sonson on 09/10/17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AllApplicationsViewController.h"

@implementation AllApplicationsViewController

#pragma mark -
#pragma mark Override

- (id)init {
	if ((self = [super initWithNibName:@"AllApplicationsViewController" bundle:nil])) {
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
	}
	return self;
}

#pragma mark -
#pragma mark dealloc

- (void) dealloc {
	[[self view] removeFromSuperview];
	[super dealloc];
}

@end

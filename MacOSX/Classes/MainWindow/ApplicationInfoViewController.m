//
//  ApplicationInfoViewController.m
//
//  Created by sonson on 09/10/17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ApplicationInfoViewController.h"
#import "ApplicationInfo.h"

@implementation ApplicationInfoViewController

@synthesize contentInfo;

#pragma mark -
#pragma mark Override

- (void)loadView {
	[super loadView];
	[iconView setImage:contentInfo.icon];
	[iconView2 setImage:contentInfo.icon];
	[titleField setStringValue:contentInfo.name];
}

- (id)init {
	if ((self = [super initWithNibName:@"ApplicationInfoViewController" bundle:nil])) {
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
	[contentInfo release];
	[super dealloc];
}

@end

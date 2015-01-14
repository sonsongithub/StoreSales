//
//  ContentViewController.m
//  StoreSales
//
//  Created by sonson on 09/10/17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ContentViewController.h"

// Information type
#import "ApplicationInfo.h"
#import "CountryInfo.h"

// Parent
#import "MainWindowController.h"

// ViewControllers
#import "AllApplicationsViewController.h"
#import "ApplicationInfoViewController.h"

@implementation ContentViewController

@dynamic contentInfo;

#pragma mark -
#pragma mark Accessor

- (void)setContentInfo:(id)newValue {
	if (contentInfo != newValue) {
		[contentInfo release];
		contentInfo = [newValue retain];
		[self reloadContent];
	}
}

#pragma mark -
#pragma mark Instance method

- (void)reloadContent {
	// release existing controller
	[controller release];
	
	if ([contentInfo isKindOfClass:[NSString class]]) {
		if ([contentInfo isEqualToString:kOutlineApplication]) {
			controller = [[AllApplicationsViewController alloc] init];
		}
		else if ([contentInfo isEqualToString:kOutlineCountries]) {
		}
	}
	else if ([contentInfo isKindOfClass:[ApplicationInfo class]]) {
		controller = [[ApplicationInfoViewController alloc] init];
		[controller setContentInfo:contentInfo];
	}
	else if ([contentInfo isKindOfClass:[CountryInfo class]]) {
		//controller = [[CountryInfoViewController alloc] init];
		//[controller setContentInfo:contentInfo];
	}
	
	// adjust new content view
	[[self view] addSubview:[controller view]];
	[[controller view] setFrame:[[self view] frame]];
}

#pragma mark -
#pragma mark Override

- (id)init {
	if ((self = [super initWithNibName:@"ContentViewController" bundle:nil])) {
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
	[contentInfo release];
	[super dealloc];
}


@end

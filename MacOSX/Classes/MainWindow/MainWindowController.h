//
//  MainViewController.h
//
//  Created by sonson on 09/10/16.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ApplicationInfo;
@class CountryInfo;
@class ContentViewController;

extern NSString *kOutlineApplication;
extern NSString *kOutlineCountries;

@interface MainWindowController : NSWindowController <NSSplitViewDelegate> {
	IBOutlet NSOutlineView	*outlineView;
	IBOutlet NSSearchField	*searchField;
	IBOutlet NSSplitView	*splitView;
	IBOutlet NSView			*dummy;
	IBOutlet NSView			*rightPane;
	
	ContentViewController	*contentViewController;
}

#pragma mark -
#pragma mark class method
+ (MainWindowController*)sharedInstance;

#pragma mark -
#pragma mark IBAction implementation
- (IBAction)didChangeSearchField:(id)sender;

#pragma mark -
#pragma mark Instance method
- (void)obtainApplicationInfo:(ApplicationInfo**)applicationInfo countryInfo:(CountryInfo**)countryInfo ofItem:(id)item;
- (NSArray*)keysFromApplicationInfo;
- (NSArray*)keysFromCountryInfo;

@end

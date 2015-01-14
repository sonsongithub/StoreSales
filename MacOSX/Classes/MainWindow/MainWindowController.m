//
//  MainViewController.m
//
//  Created by sonson on 09/10/16.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MainWindowController.h"
#import "ImageAndTextCell.h"
#import "ApplicationInfo.h"
#import "CountryInfo.h"
#import "ContentViewController.h"

NSString *kOutlineApplication = @"kOutlineApplication";
NSString *kOutlineCountries = @"kOutlineCountries";

MainWindowController *sharedMainViewController = nil;

@implementation MainWindowController

#pragma mark -
#pragma mark class method

+ (MainWindowController*)sharedInstance {
	if (sharedMainViewController == nil) {
		sharedMainViewController = [[MainWindowController alloc] initWithWindowNibName:@"MainWindowController"];
	}
	return sharedMainViewController;
}

#pragma mark -
#pragma mark IBAction implementation

- (IBAction)didChangeSearchField:(id)sender {
	DNSLogMethod
	DNSLog(@"%@", [sender stringValue]);
	[self keysFromApplicationInfo];
	[outlineView reloadData];
}

#pragma mark -
#pragma mark Instance method

- (void)obtainApplicationInfo:(ApplicationInfo**)applicationInfo countryInfo:(CountryInfo**)countryInfo ofItem:(id)item {
	*applicationInfo = [[ApplicationInfo sharedApplicationInfoDictionary] objectForKey:item];
	if (*applicationInfo == nil) {
		*countryInfo = [[CountryInfo sharedCountryInfoDictionary] objectForKey:item];
	}
}

- (NSArray*)keysFromApplicationInfo {
	if ([[searchField stringValue] length] == 0) {
		return [[ApplicationInfo sharedApplicationInfoDictionary] allKeys];
	}
	
	NSArray *keys = [[ApplicationInfo sharedApplicationInfoDictionary] allKeys];
	NSMutableArray *array = [NSMutableArray array];
	
	for (NSString *key in keys) {
		ApplicationInfo *info = [[ApplicationInfo sharedApplicationInfoDictionary] objectForKey:key];
		if ([info.name rangeOfString:[searchField stringValue] options:NSCaseInsensitiveSearch].location != NSNotFound) {
			[array addObject:key];
		}
	}
	
	return array;
}

- (NSArray*)keysFromCountryInfo {
	if ([[searchField stringValue] length] == 0) {
		return [[CountryInfo sharedCountryInfoDictionary] allKeys];
	}
	
	NSArray *keys = [[CountryInfo sharedCountryInfoDictionary] allKeys];
	NSMutableArray *array = [NSMutableArray array];
	
	for (NSString *key in keys) {
		CountryInfo *info = [[CountryInfo sharedCountryInfoDictionary] objectForKey:key];
		if ([info.name rangeOfString:[searchField stringValue] options:NSCaseInsensitiveSearch].location != NSNotFound) {
			[array addObject:key];
		}
	}
	
	return array;
}

#pragma mark -
#pragma mark NSOutlineViewDelegate

- (int)outlineView:(NSOutlineView *)anOutlineView numberOfChildrenOfItem:(id)item {
	DNSLogMethod
	if ([item isEqualToString:kOutlineApplication]) {
		return [[self keysFromApplicationInfo] count];
	}
	else if ([item isEqualToString:kOutlineCountries]) {
		return [[self keysFromCountryInfo] count];
	}
	else if (item == nil) {
		// root
		return 1;
	}
	return 0;
}  
  
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	DNSLogMethod
	if ([item isEqualToString:kOutlineApplication]) {
		return YES;
	}
	else if ([item isEqualToString:kOutlineCountries]) {
		return YES;
	}
	return NO;
}  

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {  
	DNSLog(@"[child ofItem] index:%d item:%@", index, item);
    if (item == nil) {  
		// root point
		if (index == 0)
			return kOutlineApplication;
		if (index == 1)
			return kOutlineCountries;
    }
	else {
		if ([item isEqualToString:kOutlineApplication]) {
			return [[self keysFromApplicationInfo] objectAtIndex:index];
		}
		else if ([item isEqualToString:kOutlineCountries]) {
			return [[self keysFromCountryInfo] objectAtIndex:index];
		}
    }  
	return @"";
}  

- (BOOL)outlineView:(NSOutlineView *)anOutlineView shouldSelectItem:(id)item {
	DNSLogMethod
	ApplicationInfo *applicationInfo = nil;
	CountryInfo *countryInfo = nil;

	if ([item isEqualToString:kOutlineApplication]) {
		DNSLog(@"Clicked %@", NSLocalizedString(kOutlineApplication, nil));
		[contentViewController setContentInfo:kOutlineApplication];
		
	}
	else if ([item isEqualToString:kOutlineCountries]) {
		DNSLog(@"Clicked %@", NSLocalizedString(kOutlineCountries, nil));
	}
	else {
		[self obtainApplicationInfo:&applicationInfo countryInfo:&countryInfo ofItem:item];
		if (applicationInfo) {
			DNSLog(@"Clicked %@", applicationInfo);
			[contentViewController setContentInfo:applicationInfo];
		}
		else if (countryInfo) {
			DNSLog(@"Clicked %@", countryInfo);
			[contentViewController setContentInfo:countryInfo];
		}
	}
	return YES;
}

-(BOOL)outlineView:(NSOutlineView*)outlineView isGroupItem:(id)item {
	if ([item isEqualToString:kOutlineApplication]) {
		return YES;
	}
	else {
		return NO;
	}
}

void dumpSubview( NSView* view ) {
	NSLog( @"dumpSubview=%s", class_getName([view class]) );
	for( NSView *subview in [view subviews] ) {
		dumpSubview( subview );
	}
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	ImageAndTextCell *imageAndTextCell = (ImageAndTextCell*)cell;
	
	ApplicationInfo *applicationInfo = nil;
	CountryInfo *countryInfo = nil;
	
	if ([item isEqualToString:kOutlineApplication]) {
		[imageAndTextCell setImage:nil];
		dumpSubview([imageAndTextCell controlView]);
		
	}
	else if ([item isEqualToString:kOutlineCountries]) {
		[imageAndTextCell setImage:nil];
	}
	else {
		[self obtainApplicationInfo:&applicationInfo countryInfo:&countryInfo ofItem:item];
		if (applicationInfo) {
			[imageAndTextCell setImage:applicationInfo.icon];
			//[imageAndTextCell setImage:nil];			
		}
		else if (countryInfo) {
			[imageAndTextCell setImage:countryInfo.flagImage];
		}
	}
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	ApplicationInfo *applicationInfo = nil;
	CountryInfo *countryInfo = nil;
	
	if ([item isEqualToString:kOutlineApplication]) {
		return NSLocalizedString(kOutlineApplication, nil);
	}
	else if ([item isEqualToString:kOutlineCountries]) {
		return NSLocalizedString(kOutlineCountries, nil);
	}
	else {
		[self obtainApplicationInfo:&applicationInfo countryInfo:&countryInfo ofItem:item];
		if (applicationInfo) {
			return applicationInfo.name;
		}
		else if (countryInfo) {
			return countryInfo.name;
		}
	}
	return @"";
}

#pragma mark -
#pragma mark NSSplitViewDelegate

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex {
	DNSLogMethod
	DNSLog(@"%d=%lf", dividerIndex, proposedMin);
	if (dividerIndex == 0) {
		if (proposedMin < 150) {
			return 150;
		}
	}
	return proposedMin;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex {
	DNSLogMethod
	DNSLog(@"%d=%lf", dividerIndex, proposedMax);
	if (dividerIndex == 0) {
		if (proposedMax > 250) {
			return 250;
		}
	}
	return proposedMax;
}

#pragma mark -
#pragma mark NSWindowControllerDelegate

- (void)windowDidLoad {
	DNSLogMethod
	[super windowDidLoad];
	[outlineView expandItem:nil expandChildren:YES];
	[splitView setDelegate:self];

	[rightPane addSubview:[contentViewController view]];
	[[contentViewController view] setFrame:[rightPane frame]];
	
	// apply our custom ImageAndTextCell for rendering the first column's cells
	NSTableColumn *tableColumn = [outlineView tableColumnWithIdentifier:@"LeftPane"];
	ImageAndTextCell *imageAndTextCell = [[[ImageAndTextCell alloc] init] autorelease];
	[imageAndTextCell setEditable:YES];
	[tableColumn setDataCell:imageAndTextCell];
	
	[outlineView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
}

#pragma mark -
#pragma mark Override

- (void)showWindow:(id)sender {
	[[self window] center];
	[super showWindow:sender];
}

- (id)initWithWindowNibName:(NSString *)windowNibName {
	if ((self = [super initWithWindowNibName:windowNibName])) {
		contentViewController = [[ContentViewController alloc] init];
	}
	return self;
}

#pragma mark -
#pragma mark dealloc

- (void) dealloc {
	[contentViewController release];
	[super dealloc];
}


@end

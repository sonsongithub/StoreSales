//
//  CountryTableViewController.m
//  StoreSales
//
//  Created by sonson on 09/03/05.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CountryTableViewController.h"
#import "CountrySales.h"
#import "CountryCell.h"
#import "SNButtonBar.h"
#import "CountriesTotalGraphView.h"
#import "GraphView.h"
#import "IconDrawerButton.h"

@implementation CountryTableViewController

@synthesize cells;
@synthesize backgroundImageView;
@synthesize buttonbar;

#pragma mark -
#pragma mark cell, reload method

- (void)reload {
	// dummy?
}

- (void)toggleButtonbar:(BOOL)forwarding {
	DNSLogMethod
	int current = buttonbar.selectedIndex;
	int count = [buttonbar.buttons count];
	
	if (forwarding) {
		if (current == (count - 1)) {
			current = 0;
		}
		else {
			current++;
		}
	}
	else {
		if (current == 0) {
			current = count - 1;
		}
		else {
			current--;
		}
	}
	buttonbar.selectedIndex = current;
	
	if (buttonbar.selectedIndex == 0) {
		UIAppDelegate.currentOrderType = CellOrderSales;
	}
	else if (buttonbar.selectedIndex == 1) {
		UIAppDelegate.currentOrderType = CellOrderUnits;
	}
	else if (buttonbar.selectedIndex == 2) {
		UIAppDelegate.currentOrderType = CellOrderUpgrade;
	}
	[self reload];
}

- (NSString*)graphTitle {
	float totalValue = 0;
	for (CountrySales *sales in cells) {
		totalValue += sales.value;
	}
	if (UIAppDelegate.currentOrderType == CellOrderSales) {
		return [NSString stringWithFormat:NSLocalizedString(@"Sales - %@", nil), [UIAppDelegate.salesFormatter stringFromNumber:[NSNumber numberWithInt:(int)totalValue]]];
	}
	else if (UIAppDelegate.currentOrderType == CellOrderUnits) {
		return [NSString stringWithFormat:NSLocalizedString(@"Units - %@", nil), [UIAppDelegate.unitsFormatter stringFromNumber:[NSNumber numberWithInt:(int)totalValue]]];
	}
	else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
		return [NSString stringWithFormat:NSLocalizedString(@"Upgrade - %@", nil), [UIAppDelegate.unitsFormatter stringFromNumber:[NSNumber numberWithInt:(int)totalValue]]];
	}
	return nil;
}

- (NSString*)graphTotalText {
	return [NSString stringWithFormat:NSLocalizedString(@"%d Countries", nil), (int)[cells count]];
}

- (BOOL)haveRotateView {
	// default implementation
	return YES;
}

- (GraphView*)graphView {
	CountriesTotalGraphView *view = [[CountriesTotalGraphView alloc] initWithFrame:CGRectMake(0, 0, 480, 300)];
	[view setInfoArray:self.cells];
	view.tableViewController = self;
	return [view autorelease];
}

#pragma mark -
#pragma mark UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	DNSLogMethod
	UIImage *backImage = nil;
	if ([self.cells count] == 0) {
		backImage = [UIImage imageNamed:@"nodata.png"];
		self.tableView.hidden = YES;
	}
	else if ([self.cells count] % 2 == 1) {
		backImage = [UIImage imageNamed:@"tableViewBackOdd.png"];
		self.tableView.hidden = NO;
	}
	else {
		backImage = [UIImage imageNamed:@"tableViewBackEven.png"];
		self.tableView.hidden = NO;
	}
	[self.backgroundImageView removeFromSuperview];
	self.backgroundImageView = [[[UIImageView alloc] initWithImage:backImage] autorelease];
	[self.view addSubview:self.backgroundImageView];
	[self.view sendSubviewToBack:self.backgroundImageView];
	self.tableView.backgroundColor = [UIColor clearColor];
    return [self.cells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"WeeklyTableViewCell";
	CountryCell *cell = (CountryCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[CountryCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:CellIdentifier] autorelease];
	}
	CountrySales* sale = [self.cells objectAtIndex:indexPath.row];
	cell.sales = sale;
	cell.odd = (indexPath.row%2 == 1);
	cell.orderType = UIAppDelegate.currentOrderType;
	cell.canSelect = cellsSelectable;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark -
#pragma mark SNButtonBarDelegate

- (void)buttonBar:(SNButtonBar*)buttonBar didChangeSelectedIndex:(int)selectedIndex {
	DNSLogMethod
	DNSLog(@"%d", selectedIndex);
	if (selectedIndex == 0) {
		UIAppDelegate.currentOrderType = CellOrderSales;
	}
	else if (selectedIndex == 1) {
		UIAppDelegate.currentOrderType = CellOrderUnits;
	}
	else if (selectedIndex == 2) {
		UIAppDelegate.currentOrderType = CellOrderUpgrade;
	}
	[self reload];
}

#pragma mark -
#pragma mark Override

- (id)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];
	
	NSArray* titles = [NSArray arrayWithObjects:NSLocalizedString(@"Sales", nil), NSLocalizedString(@"Units", nil), NSLocalizedString(@"Upgrade", nil), nil];
	self.buttonbar = [SNButtonBar buttonBarWithTitles:titles];
	[self.view addSubview:self.buttonbar];
	CGRect tableFrame = self.tableView.frame;
	tableFrame.origin.y += 35;
	tableFrame.size.height = 332;
	self.tableView.frame = tableFrame;
	self.buttonbar.delegate = self;
	// self.tableView.tableHeaderView = [IconDrawerButton button];
	self.tableView.tableFooterView = [IconDrawerButton button];
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.buttonbar setSelectedIndexWithCellOrderType:UIAppDelegate.currentOrderType];
}

- (void)setTabBarItemToParentNavigationController {
	// dummy
}

- (void)dealloc {
	[backgroundImageView release];
	[cells release];
	[buttonbar release];
    [super dealloc];
}

@end

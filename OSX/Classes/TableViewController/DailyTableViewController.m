//
//  DailyTableViewController.m
//  StoreSales
//
//  Created by sonson on 09/03/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DailyTableViewController.h"
#import "SNButtonBar.h"
#import "DailyCell.h"
#import "DailyLineChartView.h"
#import "SQLiteDBController.h"

@implementation DailyTableViewController

@synthesize cells;
@synthesize backgroundImageView;
@synthesize buttonbar;

#pragma mark -
#pragma mark cell, reload method

- (void)reload {
	// dummy?
}

- (void)updateTitle {
	DNSLogMethod
	NSDate *beginDate = nil;
	NSDate *endDate = nil;
	char *sql = "select min(beginDate), max(endDate) from daily";
	sqlite3 *database = [SQLiteDBController sharedInstance].database;
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}	
	else {
		if (sqlite3_step(statement) == SQLITE_ROW) {
			beginDate = [NSDate dateWithTimeIntervalSinceReferenceDate:sqlite3_column_double(statement, 0)];
			endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:sqlite3_column_double(statement, 1)];
		}
	}
	sqlite3_finalize( statement );
	
	NSDateFormatter* temp = [[NSDateFormatter alloc] init];
	[temp setDateStyle:NSDateFormatterShortStyle];
	
	if (![[temp stringFromDate:beginDate] isEqualToString:[temp stringFromDate:endDate]]) {
		self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@", [temp stringFromDate:beginDate], [temp stringFromDate:endDate]];
	}
	else {
		self.navigationItem.title = @"";
	}
	
	[temp release];
}

- (NSString*)titleForLineChart {
	DNSLogMethod
	NSDate *beginDate = nil;
	NSDate *endDate = nil;
	char *sql = "select min(beginDate), max(endDate) from daily";
	sqlite3 *database = [SQLiteDBController sharedInstance].database;
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}	
	else {
		if (sqlite3_step(statement) == SQLITE_ROW) {
			beginDate = [NSDate dateWithTimeIntervalSinceReferenceDate:sqlite3_column_double(statement, 0)];
			endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:sqlite3_column_double(statement, 1)];
		}
	}
	sqlite3_finalize( statement );
	
	NSDateFormatter* temp = [[NSDateFormatter alloc] init];
	[temp setDateStyle:NSDateFormatterShortStyle];
	NSString *lineChartTitle = nil;
	if (UIAppDelegate.currentOrderType == CellOrderSales) {
		lineChartTitle = [NSString stringWithFormat:NSLocalizedString(@"Daily - Sales (%@ - %@)", nil), [temp stringFromDate:beginDate], [temp stringFromDate:endDate]];
	}
	else if (UIAppDelegate.currentOrderType == CellOrderUnits) {
		lineChartTitle = [NSString stringWithFormat:NSLocalizedString(@"Daily - Units (%@ - %@)", nil), [temp stringFromDate:beginDate], [temp stringFromDate:endDate]];
	}
	else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
		lineChartTitle = [NSString stringWithFormat:NSLocalizedString(@"Daily - Upgrade (%@ - %@)", nil), [temp stringFromDate:beginDate], [temp stringFromDate:endDate]];
	}
	[temp release];
	return lineChartTitle;
}

- (NSString*)subtitleForLineChart {
	return nil;
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

- (BOOL)haveRotateView {
	// default implementation
	return YES;
}

- (GraphView*)graphView {
	DailyLineChartView *view = [[DailyLineChartView alloc] initWithFrame:CGRectMake(0, 0, 480, 300)];
	view.tableViewController = self;
	[view updateData];
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
	}
	else if ([self.cells count] % 2 == 1) {
		backImage = [UIImage imageNamed:@"tableViewBackOdd.png"];
	}
	else {
		backImage = [UIImage imageNamed:@"tableViewBackEven.png"];
	}
	[self.backgroundImageView removeFromSuperview];
	self.backgroundImageView = [[[UIImageView alloc] initWithImage:backImage] autorelease];
	[self.view addSubview:self.backgroundImageView];
	[self.view sendSubviewToBack:self.backgroundImageView];
	self.tableView.backgroundColor = [UIColor clearColor];
    return [self.cells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"DailyTableViewCell";
	DailyCell *cell = (DailyCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[DailyCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:CellIdentifier] autorelease];
	}
	PeriodicalSales* sale = [self.cells objectAtIndex:indexPath.row];
	cell.sales = sale;
	cell.odd = (indexPath.row%2 == 1);
	cell.orderType = UIAppDelegate.currentOrderType;
	cell.canSelect = cellsSelectable;
	return cell;
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

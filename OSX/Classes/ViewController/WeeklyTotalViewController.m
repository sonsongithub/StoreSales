//
//  WeeklyTotalViewController.m
//  StoreSales
//
//  Created by sonson on 09/03/07.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WeeklyTotalViewController.h"
#import "ApplicationSales.h"
#import "GraphView.h"
#import "AppTotalGraphView.h"
#import "SQLiteDBController.h"
#import "PeriodicalSales.h"

@implementation WeeklyTotalViewController

@synthesize currentBeginDate;
@synthesize currentEndDate;

#pragma mark -
#pragma mark Get data

- (void)reload {
	DNSLogMethod
	double valueSumation = 0;
	self.cells = [NSMutableArray array];
	char *sql = NULL;
	if (UIAppDelegate.currentOrderType == CellOrderUnits) {
		sql = "select appleIdentifier, sum(units) from weekly where beginDate = ? and endDate = ? and productTypeIdentifier != 7 group by appleIdentifier order by sum(units) desc";
	}
	else if (UIAppDelegate.currentOrderType == CellOrderSales) {
		sql = "select appleIdentifier, sum(units * royaltyPrice/currencyTableUSD.rate*?) from weekly, currencyTableUSD where royaltyPrice > 0 and beginDate = ? and endDate = ? and productTypeIdentifier != 7 and currencyTableUSD.code = royaltyCurrency group by appleIdentifier order by sum(units * royaltyPrice/currencyTableUSD.rate*?) desc";
	}
	else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
		sql = "select appleIdentifier, sum(units) from weekly where beginDate = ? and endDate = ? and productTypeIdentifier = 7 group by appleIdentifier order by sum(units) desc";
	}
	sqlite3_stmt *statement;
	sqlite3 *database = [SQLiteDBController sharedInstance].database;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}	
	else {
		if (UIAppDelegate.currentOrderType == CellOrderUnits) {
			sqlite3_bind_int(statement, 1, [self.currentBeginDate timeIntervalSinceReferenceDate]);
			sqlite3_bind_int(statement, 2, [self.currentEndDate timeIntervalSinceReferenceDate]);
		}
		else if (UIAppDelegate.currentOrderType == CellOrderSales) {
			sqlite3_bind_double(statement, 1, UIAppDelegate.userCurrencyRate);
			sqlite3_bind_int(statement, 2, [self.currentBeginDate timeIntervalSinceReferenceDate]);
			sqlite3_bind_int(statement, 3, [self.currentEndDate timeIntervalSinceReferenceDate]);
			sqlite3_bind_double(statement, 4, UIAppDelegate.userCurrencyRate);
		}
		else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
			sqlite3_bind_int(statement, 1, [self.currentBeginDate timeIntervalSinceReferenceDate]);
			sqlite3_bind_int(statement, 2, [self.currentEndDate timeIntervalSinceReferenceDate]);
		}
		while (sqlite3_step(statement) == SQLITE_ROW) {
			char *appleIdentifier = (char *)sqlite3_column_text(statement, 0);
			if (appleIdentifier != NULL) {
				ApplicationSales *sales = [[ApplicationSales alloc] init];
				NSString *appleIdentifierString = [NSString stringWithUTF8String:appleIdentifier];
				sales.info = [UIAppDelegate applicationInfoWithAppleIdentifier:appleIdentifierString];
				sales.value = (double)sqlite3_column_double(statement, 1);
				if (UIAppDelegate.currentOrderType == CellOrderUnits) {
					sales.valueString = [UIAppDelegate.unitsFormatter stringFromNumber:[NSNumber numberWithInt:(int)sales.value]];
				}
				else if (UIAppDelegate.currentOrderType == CellOrderSales) {
					sales.valueString = [UIAppDelegate.salesFormatter stringFromNumber:[NSNumber numberWithInt:(int)sales.value]];
				}
				else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
					sales.valueString = [UIAppDelegate.unitsFormatter stringFromNumber:[NSNumber numberWithInt:(int)sales.value]];
				}
				valueSumation += sales.value;
				[self.cells addObject:sales];
				[sales release];
			}
		}
	}
	sqlite3_finalize( statement );
	// calculate ratio
	for (ApplicationSales *sales in self.cells) {
		sales.ratio = sales.value / valueSumation;
	}
	[self.tableView reloadData];
	
	NSDateFormatter* temp = [[NSDateFormatter alloc] init];
	[temp setDateStyle:NSDateFormatterShortStyle];
	if (![[temp stringFromDate:currentBeginDate] isEqualToString:[temp stringFromDate:currentEndDate]]) {
		//self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@", [temp stringFromDate:currentBeginDate], [temp stringFromDate:currentEndDate]];
		self.navigationItem.title = [NSString stringWithFormat:@"%@ -", [temp stringFromDate:currentBeginDate]];
	}
	else {
		self.navigationItem.title = @"";
	}
	[temp release];
}

- (void)updateSelectedRow {
	PeriodicalSales *sales = [parentCells objectAtIndex:selectedRow];
	self.currentBeginDate = sales.beginDate;
	self.currentEndDate = sales.endDate;
	
	// you need super class call this method after setting.
	[super updateSelectedRow];
}

#pragma mark -
#pragma mark Override TotalTableViewController

- (NSString*)graphTotalText {
	NSDateFormatter* dateFormat = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormat setDateStyle:NSDateFormatterShortStyle];
	// self.navigationItem.title = [dateFormat stringFromDate:currentBeginDate];
	return [NSString stringWithFormat:NSLocalizedString(@"%d Applications (%@-%@)", nil), (int)[cells count], [dateFormat stringFromDate:currentBeginDate], [dateFormat stringFromDate:currentEndDate]];
}

#pragma mark -
#pragma mark UITableViewDelegate, UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark Override

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self reload];
}

- (void)dealloc {
    [super dealloc];
}

@end


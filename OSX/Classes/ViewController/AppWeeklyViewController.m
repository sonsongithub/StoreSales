//
//  AppWeeklyViewController.m
//  StoreSales
//
//  Created by sonson on 09/03/07.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppWeeklyViewController.h"
#import "PeriodicalSales.h"
#import "SQLiteDBController.h"

@implementation AppWeeklyViewController

//@synthesize currentAppleIdentifier;
@synthesize currentSales;

#pragma mark -
#pragma mark Get data

- (void)reload {
	DNSLogMethod
	double value_max = 0;
	self.cells = [NSMutableArray array];
	char *sql = NULL;
	if (UIAppDelegate.currentOrderType == CellOrderUnits) {
		sql = "select beginDate, endDate, sum(units) from weekly, currencyTableUSD where productTypeIdentifier != 7 and currencyTableUSD.code = royaltyCurrency and appleIdentifier = ? group by beginDate order by endDate desc";
	}
	else if (UIAppDelegate.currentOrderType == CellOrderSales) {
		sql = "select beginDate, endDate, sum(units * royaltyPrice/currencyTableUSD.rate*?) from weekly, currencyTableUSD where royaltyPrice > 0 and productTypeIdentifier != 7 and currencyTableUSD.code = royaltyCurrency and appleIdentifier = ? group by beginDate order by endDate desc";
	}
	else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
		sql = "select beginDate, endDate, sum(units) from weekly, currencyTableUSD where productTypeIdentifier = 7 and currencyTableUSD.code = royaltyCurrency and appleIdentifier = ? group by beginDate order by endDate desc";
	}
	sqlite3_stmt *statement;
	sqlite3 *database = [SQLiteDBController sharedInstance].database;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}	
	else {
		if (UIAppDelegate.currentOrderType == CellOrderUnits) {
			sqlite3_bind_int(statement, 1, currentSales.info.appleIdentifier);
		}
		else if (UIAppDelegate.currentOrderType == CellOrderSales) {
			sqlite3_bind_double(statement, 1, UIAppDelegate.userCurrencyRate);
			sqlite3_bind_int(statement, 2, currentSales.info.appleIdentifier);
		}
		else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
			sqlite3_bind_int(statement, 1, currentSales.info.appleIdentifier);
		}
		while (sqlite3_step(statement) == SQLITE_ROW) {
			char *appleIdentifier = (char *)sqlite3_column_text(statement, 0);
			if (appleIdentifier != NULL) {
				PeriodicalSales *sales = [[PeriodicalSales alloc] init];
				sales.beginDate = [NSDate dateWithTimeIntervalSinceReferenceDate:sqlite3_column_double(statement, 0)];
				sales.endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:sqlite3_column_double(statement, 1)];
				sales.value = sqlite3_column_int(statement, 2);
				
				if (UIAppDelegate.currentOrderType == CellOrderUnits) {
					sales.valueString = [UIAppDelegate.unitsFormatter stringFromNumber:[NSNumber numberWithInt:(int)sales.value]];
				}
				else if (UIAppDelegate.currentOrderType == CellOrderSales) {
					sales.valueString = [UIAppDelegate.salesFormatter stringFromNumber:[NSNumber numberWithInt:(int)sales.value]];
				}
				else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
					sales.valueString = [UIAppDelegate.unitsFormatter stringFromNumber:[NSNumber numberWithInt:(int)sales.value]];
				}
				
				[self.cells addObject:sales];
				[sales release];
				if (value_max < sales.value) {
					value_max = sales.value;
				}
			}
		}
	}
	sqlite3_finalize( statement );
	// calculate ratio
	if (value_max > 0) {
		for (PeriodicalSales *sales in self.cells) {
			sales.ratio = sales.value / value_max;
		}
	}
	[self.tableView reloadData];
}

- (NSString*)subtitleForLineChart {
	return currentSales.info.name;
}

#pragma mark -
#pragma mark UITableViewDelegate, UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark Override

- (void)viewWillAppear:(BOOL)animated {
	DNSLogMethod
	[super viewWillAppear:animated];
	[self reload];
	self.navigationItem.title = NSLocalizedString(@"Weekly Reports", nil);
	
	DNSLog(@"%d", currentSales.info.appleIdentifier);
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	[currentSales release];
    [super dealloc];
}

@end


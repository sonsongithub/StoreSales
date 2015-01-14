//
//  AppCountriesViewController.m
//  StoreSales
//
//  Created by sonson on 09/03/07.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppCountriesViewController.h"
#import "CountrySales.h"
#import "SQLiteDBController.h"
#import "sort.h"

@implementation AppCountriesViewController

@synthesize currentSales;

#pragma mark -
#pragma mark Get data

- (void)reload {
	DNSLogMethod
	float value_max = 0;
	float total = 0;
	char *sql = NULL;
	self.cells = [NSMutableArray array];
	sqlite3 *database = [SQLiteDBController sharedInstance].database;
	
	// select from weekly
	if (UIAppDelegate.currentOrderType == CellOrderSales) {
		sql = "select countryCode, sum(royaltyPrice*units/currencyTableUSD.rate*?) from weekly, currencyTableUSD where royaltyPrice > 0 and productTypeIdentifier != 7 and currencyTableUSD.code = royaltyCurrency and appleIdentifier = ? group by countryCode order by sum(royaltyPrice*units/currencyTableUSD.rate*?) desc;";
	}
	else if (UIAppDelegate.currentOrderType == CellOrderUnits) {
		sql = "select countryCode, sum(units) from weekly where productTypeIdentifier != 7 and appleIdentifier = ? group by countryCode order by sum(units) desc;";
	}
	else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
		sql = "select countryCode, sum(units) from weekly where productTypeIdentifier = 7 and appleIdentifier = ? group by countryCode order by sum(units) desc;";
	}
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}	
	else {
		if (UIAppDelegate.currentOrderType == CellOrderSales) {
			sqlite3_bind_double(statement, 1, UIAppDelegate.userCurrencyRate);
			sqlite3_bind_int(statement, 2, currentSales.info.appleIdentifier);
			sqlite3_bind_double(statement, 3, UIAppDelegate.userCurrencyRate);
		}
		else if (UIAppDelegate.currentOrderType == CellOrderUnits) {
			sqlite3_bind_int(statement, 1, currentSales.info.appleIdentifier);
		}
		else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
			sqlite3_bind_int(statement, 1, currentSales.info.appleIdentifier);
		}
		while (sqlite3_step(statement) == SQLITE_ROW) {
			char *countryCode = (char *)sqlite3_column_text(statement, 0);
			if (countryCode != NULL) {
				CountrySales *sales = [[CountrySales alloc] init];
				NSString *countryCodeString = [NSString stringWithUTF8String:countryCode];
				sales.info = [UIAppDelegate.countryInfoDict objectForKey:countryCodeString];
				sales.value = sqlite3_column_double(statement, 1);
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
				total += sales.value;
			}
		}
	}
	sqlite3_finalize(statement);
	
	// select from daily
	if (UIAppDelegate.currentOrderType == CellOrderSales) {
		sql = "select countryCode, sum(royaltyPrice*units/currencyTableUSD.rate*?) from daily, currencyTableUSD where royaltyPrice > 0 and productTypeIdentifier != 7 and currencyTableUSD.code = royaltyCurrency and appleIdentifier = ? group by countryCode order by sum(royaltyPrice*units/currencyTableUSD.rate*?) desc;";
	}
	else if (UIAppDelegate.currentOrderType == CellOrderUnits) {
		sql = "select countryCode, sum(units) from daily where productTypeIdentifier != 7 and appleIdentifier = ? group by countryCode order by sum(units) desc;";
	}
	else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
		sql = "select countryCode, sum(units) from daily where productTypeIdentifier = 7 and appleIdentifier = ? group by countryCode order by sum(units) desc;";
	}
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}	
	else {
		if (UIAppDelegate.currentOrderType == CellOrderSales) {
			sqlite3_bind_double(statement, 1, UIAppDelegate.userCurrencyRate);
			sqlite3_bind_int(statement, 2, currentSales.info.appleIdentifier);
			sqlite3_bind_double(statement, 3, UIAppDelegate.userCurrencyRate);
		}
		else if (UIAppDelegate.currentOrderType == CellOrderUnits) {
			sqlite3_bind_int(statement, 1, currentSales.info.appleIdentifier);
		}
		else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
			sqlite3_bind_int(statement, 1, currentSales.info.appleIdentifier);
		}
		while (sqlite3_step(statement) == SQLITE_ROW) {
			char *countryCode = (char *)sqlite3_column_text(statement, 0);
			if (countryCode != NULL) {
				CountrySales *sales = [[CountrySales alloc] init];
				NSString *countryCodeString = [NSString stringWithUTF8String:countryCode];
				sales.info = [UIAppDelegate.countryInfoDict objectForKey:countryCodeString];
				sales.value = sqlite3_column_double(statement, 1);
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
				total += sales.value;
			}
		}
	}
	sqlite3_finalize(statement);
	
	// delete redundancy
	for (CountrySales *sales_i in [self.cells reverseObjectEnumerator]) {
		for (CountrySales *sales_j in [self.cells reverseObjectEnumerator]) {
			if (sales_i != sales_j) {
				if (sales_i.info.countryCode == sales_j.info.countryCode) {
					if (sales_i.value > sales_j.value) {
						[self.cells removeObject:sales_j];
					}
					else {
						[self.cells removeObject:sales_i];
					}
					DNSLog(@"delete");
					break;
				}
			}
		}
	}
	
	[self.cells sortUsingFunction:CountrySalesSort context:NULL];
	
	// calculate ratio
	total = 0;
	for (CountrySales *sales in self.cells) {
		total += sales.value;
	}
	if (value_max > 0 && total > 0) {
		for (CountrySales *sales in self.cells) {
			// sales.ratio = sales.value / value_max;
			sales.ratio = sales.value / total;
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
	self.navigationItem.title = NSLocalizedString(@"Countries", nil);
	
	DNSLog(@"%d", currentSales.info.appleIdentifier);
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	[currentSales release];
    [super dealloc];
}

@end


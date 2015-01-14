//
//  CountriesTotalViewController.m
//  StoreSales
//
//  Created by sonson on 09/03/07.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CountriesTotalViewController.h"
#import "ApplicationSales.h"
#import "ApplicationInfo.h"
#import "SQLiteDBController.h"
#import "sort.h"
#import "CountrySales.h"

@implementation CountriesTotalViewController

@synthesize currentCountryCode;
@synthesize info;

#pragma mark -
#pragma mark Get data

- (void)reload {
	DNSLogMethod
	double valueSumation = 0;
	self.cells = [NSMutableArray array];
	char *sql = NULL;
	sqlite3_stmt *statement;
	sqlite3 *database = [SQLiteDBController sharedInstance].database;
	
	// select from weekly
	if (UIAppDelegate.currentOrderType == CellOrderUnits) {
		sql = "select appleIdentifier, sum(units) from weekly where countryCode = ? and productTypeIdentifier != 7 group by appleIdentifier order by sum(units) desc";
	}
	else if (UIAppDelegate.currentOrderType == CellOrderSales) {
		sql = "select appleIdentifier, sum(units * royaltyPrice/currencyTableUSD.rate*?) from weekly, currencyTableUSD where royaltyPrice > 0 and countryCode = ? and productTypeIdentifier != 7 and currencyTableUSD.code = royaltyCurrency group by appleIdentifier order by sum(units * royaltyPrice/currencyTableUSD.rate*?) desc";
	}
	else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
		sql = "select appleIdentifier, sum(units) from weekly where countryCode = ? and productTypeIdentifier = 7 group by appleIdentifier order by sum(units) desc";
	}
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}	
	else {
		if (UIAppDelegate.currentOrderType == CellOrderUnits) {
			sqlite3_bind_text(statement, 1, [self.currentCountryCode UTF8String], [self.currentCountryCode length], SQLITE_TRANSIENT);
		}
		else if (UIAppDelegate.currentOrderType == CellOrderSales) {
			sqlite3_bind_double(statement, 1, UIAppDelegate.userCurrencyRate);
			sqlite3_bind_text(statement, 2, [self.currentCountryCode UTF8String], [self.currentCountryCode length], SQLITE_TRANSIENT);
			sqlite3_bind_double(statement, 3, UIAppDelegate.userCurrencyRate);
		}
		else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
			sqlite3_bind_text(statement, 1, [self.currentCountryCode UTF8String], [self.currentCountryCode length], SQLITE_TRANSIENT);
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
	sqlite3_finalize(statement);

	// select from daily
	if (UIAppDelegate.currentOrderType == CellOrderUnits) {
		sql = "select appleIdentifier, sum(units) from daily where countryCode = ? and productTypeIdentifier != 7 group by appleIdentifier order by sum(units) desc";
	}
	else if (UIAppDelegate.currentOrderType == CellOrderSales) {
		sql = "select appleIdentifier, sum(units * royaltyPrice/currencyTableUSD.rate*?) from daily, currencyTableUSD where royaltyPrice > 0 and countryCode = ? and productTypeIdentifier != 7 and currencyTableUSD.code = royaltyCurrency group by appleIdentifier order by sum(units * royaltyPrice/currencyTableUSD.rate*?) desc";
	}
	else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
		sql = "select appleIdentifier, sum(units) from daily where countryCode = ? and productTypeIdentifier = 7 group by appleIdentifier order by sum(units) desc";
	}
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}	
	else {
		if (UIAppDelegate.currentOrderType == CellOrderUnits) {
			sqlite3_bind_text(statement, 1, [self.currentCountryCode UTF8String], [self.currentCountryCode length], SQLITE_TRANSIENT);
		}
		else if (UIAppDelegate.currentOrderType == CellOrderSales) {
			sqlite3_bind_double(statement, 1, UIAppDelegate.userCurrencyRate);
			sqlite3_bind_text(statement, 2, [self.currentCountryCode UTF8String], [self.currentCountryCode length], SQLITE_TRANSIENT);
			sqlite3_bind_double(statement, 3, UIAppDelegate.userCurrencyRate);
		}
		else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
			sqlite3_bind_text(statement, 1, [self.currentCountryCode UTF8String], [self.currentCountryCode length], SQLITE_TRANSIENT);
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
	sqlite3_finalize(statement);	
	
	// delete redundancy
	for (ApplicationSales *sales_i in [self.cells reverseObjectEnumerator]) {
		for (ApplicationSales *sales_j in [self.cells reverseObjectEnumerator]) {
			if (sales_i != sales_j) {
				if (sales_i.info.appleIdentifier == sales_j.info.appleIdentifier) {
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
	
	[self.cells sortUsingFunction:ApplicationSalesSort context:NULL];
	
	// calculate ratio
	valueSumation = 0;
	for (ApplicationSales *sales in self.cells) {
		valueSumation += sales.value;
		
	}
	if (valueSumation > 0) {
		for (ApplicationSales *sales in self.cells) {
			sales.ratio = sales.value / valueSumation;
		}
	}
	[self.tableView reloadData];
	
}

- (void)updateSelectedRow {
	CountrySales *sales = [parentCells objectAtIndex:selectedRow];
	self.currentCountryCode = sales.info.countryCode;
	self.info = sales.info;
	self.navigationItem.title = info.name;
	
	// you need super class call this method after setting.
	[super updateSelectedRow];
}

#pragma mark -
#pragma mark Override TotalTableViewController

- (NSString*)graphTotalText {
	return [NSString stringWithFormat:NSLocalizedString(@"%d Applications (%@)", nil), (int)[cells count], info.name];
}

#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark Override

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationItem.title = info.name;
	[self reload];
}

- (void)setTabBarItemToParentNavigationController {
	UIImage *tabBarIcon = [UIImage imageNamed:@"countriesWhite.png"];
	self.navigationController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Countries", nil) image:tabBarIcon tag:0] autorelease];
}

- (void)dealloc {
	[info release];
    [super dealloc];
}

@end


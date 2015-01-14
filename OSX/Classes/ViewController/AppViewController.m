//
//  EntireViewController.m
//  StoreSales
//
//  Created by sonson on 09/02/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppViewController.h"
#import "AppInfoCell.h"
#import "AppTotalInfoCell.h"
#import "ApplicationSales.h"
#import "SNButtonBar.h"
#import "SelectOrderViewController.h"
#import "ApplicationInfo.h"
#import "AppTotalGraphView.h"
#import "SQLiteDBController.h"
#import "sort.h"

@implementation AppViewController

#pragma mark -
#pragma mark Get data

- (NSString*)pathCachePlistOfTOrderType:(CellOrderType)type {
	DNSLogMethod
	NSString *filename = nil;
	
	switch(type) {
		case CellOrderUnits:
			filename = @"AppViewControllerUnitsCache.bin";
			break;
		case CellOrderSales:
			filename = @"AppViewControllerSalesCache.bin";
			break;
		case CellOrderUpgrade:
			filename = @"AppViewControllerUpgradeCache.bin";
			break;
	}
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *cacheDirecotyPath = [NSString stringWithFormat:@"%@/cache/", documentsDirectory];
	
	BOOL isDirectory = NO;
	if ([[NSFileManager defaultManager] fileExistsAtPath:cacheDirecotyPath isDirectory:&isDirectory]) {
	}
	else {
		if([[NSFileManager defaultManager] createDirectoryAtPath:cacheDirecotyPath withIntermediateDirectories:YES attributes:nil error:nil]) {
		}
	}
	return [cacheDirecotyPath stringByAppendingPathComponent:filename];
}

- (BOOL)readCellPlistOfOrderType:(CellOrderType)type {
	DNSLogMethod
#ifdef _RAW_BYTE
	NSString *path = [self pathCachePlistOfTOrderType:type];
	DSTART_TIME_CHECK
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		FILE *fp = fopen([path UTF8String], "rb");
		self.cells = [NSMutableArray array];
		while(!feof(fp)) {
			ApplicationSales *sales = [ApplicationSales ApplicationSalesFromFile:fp];
			if (sales) {
				sales.info = [UIAppDelegate applicationInfoWithAppleIdentifier:sales.applicationIdentifierString];
				[self.cells addObject:sales];
			}
		}
		fclose(fp);
		DEND_TIME_CHECK
		return ([self.cells count] > 0);
	}
#else
	NSString *path = [self pathCachePlistOfTOrderType:type];
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		NSData *data  = [NSData dataWithContentsOfFile:path];
		NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		self.cells = [NSArray arrayWithArray:[decoder decodeObjectForKey:@"cells"]];
		[decoder finishDecoding];
		[decoder release];
		
		for (ApplicationSales *sales in self.cells) {
			sales.info = [UIAppDelegate applicationInfoWithAppleIdentifier:sales.applicationIdentifierString];
		}
		
		return ([self.cells count] > 0);
	}
#endif
	return NO;
}

- (BOOL)writeCellPlistOfOrderType:(CellOrderType)type {
	DNSLogMethod
	if ([self.cells count]) {
#ifdef _RAW_BYTE
		NSString *path = [self pathCachePlistOfTOrderType:type];
		FILE *fp = fopen([path UTF8String], "wb");
		for (ApplicationSales *sales in self.cells) {
			[sales write:fp];
		}
		fclose(fp);
#else	
		NSMutableData *data = [NSMutableData data];
		NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		NSString *path = [self pathCachePlistOfTOrderType:type];
		[encoder encodeObject:self.cells forKey:@"cells"];
		[encoder finishEncoding];
		[data writeToFile:path atomically:NO];
		[encoder release];
#endif
	}
	return YES;
}

- (void)selectFromSQLiteOrderType:(CellOrderType)type {
	DNSLogMethod
	double valueSumation = 0;
	self.cells = [NSMutableArray array];
	char *sql = NULL;
	
	// select weekly data
	if (type == CellOrderUnits) {
		sql = "select appleIdentifier, sum(units) from weekly, currencyTableUSD where productTypeIdentifier != 7 and currencyTableUSD.code = royaltyCurrency group by appleIdentifier order by sum(units) desc";
	}
	else if (type == CellOrderSales) {
		sql = "select appleIdentifier, sum(units * royaltyPrice/currencyTableUSD.rate*?) from weekly, currencyTableUSD where royaltyPrice > 0 and productTypeIdentifier != 7 and currencyTableUSD.code = royaltyCurrency group by appleIdentifier order by sum(units * royaltyPrice) desc";
	}
	else if (type == CellOrderUpgrade) {
		sql = "select appleIdentifier, sum(units) from weekly, currencyTableUSD where productTypeIdentifier = 7 and currencyTableUSD.code = royaltyCurrency group by appleIdentifier order by sum(units) desc";
	}

	sqlite3_stmt *statement;
	sqlite3 *database = [SQLiteDBController sharedInstance].database;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}	
	else {
		sqlite3_bind_double(statement, 1, UIAppDelegate.userCurrencyRate);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			char *appleIdentifier = (char *)sqlite3_column_text(statement, 0);
			if (appleIdentifier != NULL) {
				ApplicationSales *sales = [[ApplicationSales alloc] init];
				NSString *appleIdentifierString = [NSString stringWithUTF8String:appleIdentifier];
				sales.info = [UIAppDelegate applicationInfoWithAppleIdentifier:appleIdentifierString];
				//sales.info = [UIAppDelegate.applicationInfoDict objectForKey:appleIdentifierString];
				sales.value = (double)sqlite3_column_double(statement, 1);
				if (UIAppDelegate.currentOrderType == CellOrderUnits) {
					//sales.valueString = [NSString stringWithFormat:@"%d", (int)sales.value];
					sales.valueString = [UIAppDelegate.unitsFormatter stringFromNumber:[NSNumber numberWithInt:(int)sales.value]];
				}
				else if (UIAppDelegate.currentOrderType == CellOrderSales) {
					//sales.valueString = [NSString stringWithFormat:@"%@%d", UIAppDelegate.currencyDescription, (int)sales.value];
					sales.valueString = [UIAppDelegate.salesFormatter stringFromNumber:[NSNumber numberWithInt:(int)sales.value]];
				}
				else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
					//sales.valueString = [NSString stringWithFormat:@"%d", (int)sales.value];
					sales.valueString = [UIAppDelegate.unitsFormatter stringFromNumber:[NSNumber numberWithInt:(int)sales.value]];
				}
				valueSumation += sales.value;
				[self.cells addObject:sales];
				[sales release];
			}
		}
	}
	DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	sqlite3_finalize( statement );
	
	// select daily data
	if (type == CellOrderUnits) {
		sql = "select appleIdentifier, sum(units) from daily, currencyTableUSD where productTypeIdentifier != 7 and currencyTableUSD.code = royaltyCurrency group by appleIdentifier order by sum(units) desc";
	}
	else if (type == CellOrderSales) {
		sql = "select appleIdentifier, sum(units * royaltyPrice/currencyTableUSD.rate*?) from daily, currencyTableUSD where royaltyPrice > 0 and productTypeIdentifier != 7 and currencyTableUSD.code = royaltyCurrency group by appleIdentifier order by sum(units * royaltyPrice) desc";
	}
	else if (type == CellOrderUpgrade) {
		sql = "select appleIdentifier, sum(units) from daily, currencyTableUSD where productTypeIdentifier = 7 and currencyTableUSD.code = royaltyCurrency group by appleIdentifier order by sum(units) desc";
	}
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}	
	else {
		sqlite3_bind_double(statement, 1, UIAppDelegate.userCurrencyRate);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			char *appleIdentifier = (char *)sqlite3_column_text(statement, 0);
			if (appleIdentifier != NULL) {
				ApplicationSales *sales = [[ApplicationSales alloc] init];
				NSString *appleIdentifierString = [NSString stringWithUTF8String:appleIdentifier];
				sales.info = [UIAppDelegate applicationInfoWithAppleIdentifier:appleIdentifierString];
				//sales.info = [UIAppDelegate.applicationInfoDict objectForKey:appleIdentifierString];
				sales.value = (double)sqlite3_column_double(statement, 1);
				if (UIAppDelegate.currentOrderType == CellOrderUnits) {
					//sales.valueString = [NSString stringWithFormat:@"%d", (int)sales.value];
					sales.valueString = [UIAppDelegate.unitsFormatter stringFromNumber:[NSNumber numberWithInt:(int)sales.value]];
				}
				else if (UIAppDelegate.currentOrderType == CellOrderSales) {
					//sales.valueString = [NSString stringWithFormat:@"%@%d", UIAppDelegate.currencyDescription, (int)sales.value];
					sales.valueString = [UIAppDelegate.salesFormatter stringFromNumber:[NSNumber numberWithInt:(int)sales.value]];
				}
				else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
					//sales.valueString = [NSString stringWithFormat:@"%d", (int)sales.value];
					sales.valueString = [UIAppDelegate.unitsFormatter stringFromNumber:[NSNumber numberWithInt:(int)sales.value]];
				}
				valueSumation += sales.value;
				[self.cells addObject:sales];
				[sales release];
			}
		}
	}
	DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	sqlite3_finalize( statement );

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
	for (ApplicationSales *sales in self.cells) {
		sales.ratio = sales.value / valueSumation;
	}
}

- (void)updateTitle {
	double valueSumation = 0;
	
	// calculate ratio
	for (ApplicationSales *sales in self.cells) {
		valueSumation += sales.value;
	}
	
	if (valueSumation > 0) {
		if (UIAppDelegate.currentOrderType == CellOrderUnits) {
			self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Total %@", nil), [UIAppDelegate.unitsFormatter stringFromNumber:[NSNumber numberWithInt:(int)valueSumation]]];
		}
		else if (UIAppDelegate.currentOrderType == CellOrderSales) {
			self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Total %@", nil), [UIAppDelegate.salesFormatter stringFromNumber:[NSNumber numberWithInt:(int)valueSumation]]];
		}
		else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
			self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Total %@", nil), [UIAppDelegate.unitsFormatter stringFromNumber:[NSNumber numberWithInt:(int)valueSumation]]];
		}
	}
	else {
		self.navigationItem.title = @"";
	}
}

- (void)reload {
	if ([self readCellPlistOfOrderType:UIAppDelegate.currentOrderType]) {
	}
	else {
		[self selectFromSQLiteOrderType:UIAppDelegate.currentOrderType];
		[self writeCellPlistOfOrderType:UIAppDelegate.currentOrderType];
	}
	[self.tableView reloadData];
	[self updateTitle];
}

#pragma mark -
#pragma mark UITableViewDelegate, UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
	SelectOrderViewController* con = [[SelectOrderViewController alloc] initWithStyle:UITableViewStylePlain];
	ApplicationSales *sales = [cells objectAtIndex:indexPath.row];
	con.appleIdentifier = sales.info.appleIdentifier;
	con.sales = sales;
	[self.navigationController pushViewController:con animated:YES];
	[con release];
}

#pragma mark -
#pragma mark SNButtonBarDelegate

- (void)buttonBar:(SNButtonBar*)buttonBar didChangeSelectedIndex:(int)selectedIndex {
	DNSLogMethod
	DNSLog(@"%f,%f", self.tableView.bounds.size.width, self.tableView.bounds.size.height);
	DNSLog(@"%f,%f", self.view.bounds.size.width, self.view.bounds.size.height);
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

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	cellsSelectable = YES;
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
	[self reload];
	[self setNavigationItem];
}

- (void)setTabBarItemToParentNavigationController {
	UIImage *tabBarIcon = [UIImage imageNamed:@"app.png"];
	self.navigationController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"App", nil) image:tabBarIcon tag:0] autorelease];
}

- (void)dealloc {
    [super dealloc];
}

@end

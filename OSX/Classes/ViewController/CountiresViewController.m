//
//  CountiresViewController.m
//  StoreSales
//
//  Created by sonson on 09/02/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CountiresViewController.h"
#import "CountryInfo.h"
#import "CountrySales.h"
#import "CountriesTotalViewController.h"
#import "SQLiteDBController.h"
#import "sort.h"

@implementation CountiresViewController

#pragma mark -
#pragma mark Get data

- (NSString*)pathCachePlistOfTOrderType:(CellOrderType)type {
	DNSLogMethod
	NSString *filename = nil;
	
	switch(type) {
		case CellOrderUnits:
			filename = @"CountiresViewControllerUnitsCache.bin";
			break;
		case CellOrderSales:
			filename = @"CountiresViewControllerSalesCache.bin";
			break;
		case CellOrderUpgrade:
			filename = @"CountiresViewControllerUpgradeCache.bin";
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
			CountrySales*sales = [CountrySales CountrySalesFromFile:fp];
			sales.info = [UIAppDelegate.countryInfoDict objectForKey:sales.countryCode];
			[self.cells addObject:sales];
		}
		fclose(fp);
		DEND_TIME_CHECK
		return YES;
	}
#else
	NSString *path = [self pathCachePlistOfTOrderType:type];
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		NSData *data  = [NSData dataWithContentsOfFile:path];
		NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		self.cells = [NSArray arrayWithArray:[decoder decodeObjectForKey:@"cells"]];
		[decoder finishDecoding];
		[decoder release];
		for (CountrySales *sales in self.cells) {
			sales.info = [UIAppDelegate.countryInfoDict objectForKey:sales.countryCode];
		}
		return YES;
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
	for (CountrySales *sales in self.cells) {
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
	char *sql = NULL;
	float value_max = 0;
	float total = 0;
	self.cells = [NSMutableArray array];
	sqlite3_stmt *statement;
	sqlite3 *database = [SQLiteDBController sharedInstance].database;
	
	// select from weekly
	if (UIAppDelegate.currentOrderType == CellOrderSales) {
		sql = "select countryCode, sum(royaltyPrice*units/currencyTableUSD.rate*?) from weekly, currencyTableUSD where royaltyPrice > 0 and productTypeIdentifier != 7 and currencyTableUSD.code = royaltyCurrency group by countryCode order by sum(royaltyPrice*units/currencyTableUSD.rate*?) desc;";
	}
	else if (UIAppDelegate.currentOrderType == CellOrderUnits) {
		sql = "select countryCode, sum(units) from weekly where productTypeIdentifier != 7 group by countryCode order by sum(units) desc;";
	}
	else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
		sql = "select countryCode, sum(units) from weekly where productTypeIdentifier = 7 group by countryCode order by sum(units) desc;";
	}
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}	
	else {
		sqlite3_bind_double(statement, 1, UIAppDelegate.userCurrencyRate);
		sqlite3_bind_double(statement, 2, UIAppDelegate.userCurrencyRate);
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
				if (value_max < sales.value) {
					value_max = sales.value;
				}
				total += sales.value;
				[sales release];
			}
		}
	}
	sqlite3_finalize(statement);
	
	// select from daily
	if (UIAppDelegate.currentOrderType == CellOrderSales) {
		sql = "select countryCode, sum(royaltyPrice*units/currencyTableUSD.rate*?) from daily, currencyTableUSD where royaltyPrice > 0 and productTypeIdentifier != 7 and currencyTableUSD.code = royaltyCurrency group by countryCode order by sum(royaltyPrice*units/currencyTableUSD.rate*?) desc;";
	}
	else if (UIAppDelegate.currentOrderType == CellOrderUnits) {
		sql = "select countryCode, sum(units) from daily where productTypeIdentifier != 7 group by countryCode order by sum(units) desc;";
	}
	else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
		sql = "select countryCode, sum(units) from daily where productTypeIdentifier = 7 group by countryCode order by sum(units) desc;";
	}
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}	
	else {
		sqlite3_bind_double(statement, 1, UIAppDelegate.userCurrencyRate);
		sqlite3_bind_double(statement, 2, UIAppDelegate.userCurrencyRate);
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
				if (value_max < sales.value) {
					value_max = sales.value;
				}
				total += sales.value;
				[sales release];
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
			//sales.ratio = sales.value / value_max;
			sales.ratio = sales.value / total;
		}
	}
}

- (void)updateTitle {
	int count = [cells count];
	if (count) {
		self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"%d Countries", nil), count];
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
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
	CountriesTotalViewController* con = [[CountriesTotalViewController alloc] initWithStyle:UITableViewStylePlain];
		
	con.parentCells = self.cells;
	con.selectedRow = indexPath.row;
	
	DNSLog(@"%@", con.currentCountryCode);
	[self.navigationController pushViewController:con animated:YES];
	[con release];
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
	UIImage *tabBarIcon = [UIImage imageNamed:@"countriesWhite.png"];
	self.navigationController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Countries", nil) image:tabBarIcon tag:0] autorelease];
}

- (void)dealloc {
    [super dealloc];
}

@end

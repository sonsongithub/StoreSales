//
//  WeeklyViewController.m
//  StoreSales
//
//  Created by sonson on 09/02/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WeeklyViewController.h"
#import "PeriodicalSales.h"
#import "WeeklyTotalViewController.h"
#import "LineChartView.h"
#import "SQLiteDBController.h"

@implementation WeeklyViewController

#pragma mark -
#pragma mark Get data

- (NSString*)pathCachePlistOfTOrderType:(CellOrderType)type {
	DNSLogMethod
	NSString *filename = nil;
	
	switch(type) {
		case CellOrderUnits:
			filename = @"WeeklyViewControllerUnitsCache.bin";
			break;
		case CellOrderSales:
			filename = @"WeeklyViewControllerSalesCache.bin";
			break;
		case CellOrderUpgrade:
			filename = @"WeeklyViewControllerUpgradeCache.bin";
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
			PeriodicalSales *sales = [PeriodicalSales PeriodicalSalesFromFile:fp];
			if (sales)
				[self.cells addObject:sales];
		}
		fclose(fp);
		DEND_TIME_CHECK
		return YES;
	}
#else
	NSString *path = [self pathCachePlistOfTOrderType:type];
	DSTART_TIME_CHECK
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		NSData *data  = [NSData dataWithContentsOfFile:path];
		NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		self.cells = [NSArray arrayWithArray:[decoder decodeObjectForKey:@"cells"]];
		[decoder finishDecoding];
		[decoder release];
		for (PeriodicalSales *sales in self.cells) {
		}
		DEND_TIME_CHECK
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
	for (PeriodicalSales *sales in self.cells) {
		if (![sales write:fp]) {
			DNSLog(@"Write failed");
		}
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
	float value_max = 0;
	float total = 0;
	self.cells = [NSMutableArray array];
	char *sql = NULL;
	if (UIAppDelegate.currentOrderType == CellOrderUnits) {
		sql = "select beginDate, endDate, sum(units) from weekly, currencyTableUSD where productTypeIdentifier != 7 and currencyTableUSD.code = royaltyCurrency group by beginDate order by endDate desc";
	}
	else if (UIAppDelegate.currentOrderType == CellOrderSales) {
		sql = "select beginDate, endDate, sum(units * royaltyPrice/currencyTableUSD.rate*?) from weekly, currencyTableUSD where royaltyPrice > 0 and productTypeIdentifier != 7 and currencyTableUSD.code = royaltyCurrency group by beginDate order by endDate desc";
	}
	else if (UIAppDelegate.currentOrderType == CellOrderUpgrade) {
		sql = "select beginDate, endDate, sum(units) from weekly, currencyTableUSD where productTypeIdentifier = 7 and currencyTableUSD.code = royaltyCurrency group by beginDate order by endDate desc";
	}
	sqlite3 *database = [SQLiteDBController sharedInstance].database;
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}	
	else {
		sqlite3_bind_double(statement, 1, UIAppDelegate.userCurrencyRate);
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
				if (value_max < sales.value) {
					value_max = sales.value;
				}
				total += sales.value;
				[sales release];
			}
		}
	}
	sqlite3_finalize( statement );
	// calculate ratio
	if (value_max > 0 && total > 0) {
		for (PeriodicalSales *sales in self.cells) {
			sales.ratio = sales.value / value_max;
			//sales.ratio = sales.value / total;
		}
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

- (NSString*)subtitleForLineChart {
	return NSLocalizedString(@"All Applications", nil);
}

#pragma mark -
#pragma mark UITableViewDelegate, UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
	WeeklyTotalViewController* con = [[WeeklyTotalViewController alloc] initWithStyle:UITableViewStylePlain];
	
	con.parentCells = cells;
	con.selectedRow = indexPath.row;
	
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
	UIImage *tabBarIcon = [UIImage imageNamed:@"weeklyWhite.png"];
	self.navigationController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Weekly", nil) image:tabBarIcon tag:0] autorelease];
}

- (void)dealloc {
    [super dealloc];
}


@end

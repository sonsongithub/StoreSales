//
//  SQLiteDBController.m
//  StoreSales
//
//  Created by sonson on 09/05/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SQLiteDBController.h"

#import "YAHCurrencyTool.h"

SQLiteDBController* singletonSQLiteDB = nil;

@implementation SQLiteDBController

@synthesize database;

#pragma mark -
#pragma mark Class method

+ (SQLiteDBController*)sharedInstance {
	if (singletonSQLiteDB == nil) {
		singletonSQLiteDB = [[SQLiteDBController alloc] init];
	}
	return singletonSQLiteDB;
}

#pragma mark -
#pragma mark Instance method

- (id)infoValueForKey:(NSString*)key {
	// to get application's bundle name
	if ([[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:key])
		return [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:key];
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:key];
}

- (int)getSendLog {
	char *sql = "select count(*) from sendLog";
	int number_of_record = 0;
	sqlite3_stmt *statement = NULL;	
	if (sqlite3_prepare_v2( database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database ));
	}
	else {
		sqlite3_step(statement);
		number_of_record = sqlite3_column_int(statement, 0);
	}
	sqlite3_finalize(statement);
	return number_of_record;
}

- (int)getRecordLogOfDailyLog {
	char *sql = "select count(*) from recordLog where reportTimeType = \"ITCLogDaily\"";
	int number_of_record = 0;
	sqlite3_stmt *statement = NULL;	
	if (sqlite3_prepare_v2( database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database ));
	}
	else {
		sqlite3_step(statement);
		number_of_record = sqlite3_column_int(statement, 0);
	}
	sqlite3_finalize(statement);
	return number_of_record;
}

- (int)getRecordLogOfWeeklyLog {
	char *sql = "select count(*) from recordLog where reportTimeType = \"ITCLogWeekly\"";
	int number_of_record = 0;
	sqlite3_stmt *statement = NULL;	
	if (sqlite3_prepare_v2( database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database ));
	}
	else {
		sqlite3_step(statement);
		number_of_record = sqlite3_column_int(statement, 0);
	}
	sqlite3_finalize(statement);
	return number_of_record;
}

- (void)getRecordLogOfDailyLog:(int*)dailyLog weeklyLog:(int*)weeklyLog {
	*dailyLog = [self getRecordLogOfDailyLog];
	*weeklyLog = [self getRecordLogOfWeeklyLog];
}

#pragma mark -
#pragma mark Table migration and initialization method

- (void)makeTables {
	DNSLogMethod
	//
	// table, schema
	//
	// to save applicaton identifier, name, name, icon image
	char *application_table = "CREATE TABLE application (appleIdentifier INTEGER PRIMARY KEY, vendorIdentifier TEXT, icon BLOB, name TEXT);";
	
	// to save currency exchange rates
	char *currencyTableUSD_table = "CREATE TABLE currencyTableUSD (rate NUMERIC, code TEXT);";
	
	// to save daily and weekly sales log
	char *daily_table = "CREATE TABLE daily (dateIdentifier TEXT, CMA TEXT, ISAN TEXT, ISRC TEXT, UPC TEXT, appleIdentifier TEXT, artistShow TEXT, assetContentFlavor TEXT, beginDate NUMERIC, countryCode TEXT, customerCurrency TEXT, customerPrice NUMERIC, endDate NUMERIC, id INTEGER PRIMARY KEY, labelStudioNetwork TEXT, preorder TEXT, productTypeIdentifier NUMERIC, provider TEXT, providerCountry TEXT, royaltyPrice NUMERIC, royaltyCurrency NUMERIC, seasonPass TEXT, titleEpisodeSeason TEXT, units NUMERIC, vendorIdentifier TEXT);";
	char *weekly_tabl = "CREATE TABLE weekly (dateIdentifier TEXT, CMA TEXT, ISAN TEXT, ISRC TEXT, UPC TEXT, appleIdentifier TEXT, artistShow TEXT, assetContentFlavor TEXT, beginDate NUMERIC, countryCode TEXT, customerCurrency TEXT, customerPrice NUMERIC, endDate NUMERIC, id INTEGER PRIMARY KEY, labelStudioNetwork TEXT, preorder TEXT, productTypeIdentifier NUMERIC, provider TEXT, providerCountry TEXT, royaltyPrice NUMERIC, royaltyCurrency TEXT, seasonPass TEXT, titleEpisodeSeason TEXT, units NUMERIC, vendorIdentifier TEXT);";
	
	// history of own saved log into above daily, weekly tables
	char *recordLog_table = "CREATE TABLE recordLog (artist TEXT, beginDate NUMERIC, endDate NUMERIC, reportTimeType TEXT, vendorID TEXT);";
	
	//
	// history of sending to iPhone, for only MacOSX
	//
	char *sendLog_table = "CREATE TABLE sendLog (artist TEXT, beginDate NUMERIC, endDate NUMERIC, reportTimeType TEXT, vendorID TEXT);";
	
	// Exec. schema
	sqlite3_exec(database, application_table, NULL, NULL, NULL);
	sqlite3_exec(database, currencyTableUSD_table, NULL, NULL, NULL);
	sqlite3_exec(database, daily_table, NULL, NULL, NULL);
	sqlite3_exec(database, recordLog_table, NULL, NULL, NULL);
	sqlite3_exec(database, sendLog_table, NULL, NULL, NULL);
	sqlite3_exec(database, weekly_tabl, NULL, NULL, NULL);
	
	//
	// 20100117 add parent identifier column
	//
	char *add_daily_parentIdentifier = "ALTER TABLE daily ADD COLUMN parentIdentifier TEXT;";
	char *add_weekly_parentIdentifier = "ALTER TABLE weekly ADD COLUMN parentIdentifier TEXT;";
	sqlite3_exec(database, add_daily_parentIdentifier, NULL, NULL, NULL);
	sqlite3_exec(database, add_weekly_parentIdentifier, NULL, NULL, NULL);
	
	//
	// 20100123 repair parent identifier column. 
	// parent identifierは，今まで' 'をNULLのかわりに代入されていたっぽいので，NULLで置き換える
	//
	char *repair_parentIdentifier_daily = "update daily set parentIdentifier=NULL where parentIdentifier=' ';";
	char *repair_parentIdentifier_weekly = "update weekly set parentIdentifier=NULL where parentIdentifier=' ';";
	sqlite3_exec(database, repair_parentIdentifier_daily, NULL, NULL, NULL);
	sqlite3_exec(database, repair_parentIdentifier_weekly, NULL, NULL, NULL);
	
	//
	// 20101219 デフォルト通貨レートを読み込むようにした
	//
	[YAHCurrencyTool readCurrencyInfoPlistIntoDatabase:database];
}

- (void)deleteAllRecordFromAllTables {
	//
	// delete query
	//
	char *delete_from_application_table = "delete from application;";
//	char *delete_from_currencyTableUSD_table = "delete from currencyTableUSD;";
	char *delete_from_daily_table = "delete from daily;";
	char *delete_from_weekly_tabl = "delete from weekly;";
	char *delete_from_recordLog_table = "delete from recordLog;";
	char *delete_from_sendLog_table = "delete from sendLog;";
	
	//
	// Exec query
	//
	sqlite3_exec(database, delete_from_application_table, NULL, NULL, NULL);
//	sqlite3_exec(database, delete_from_currencyTableUSD_table, NULL, NULL, NULL);
	sqlite3_exec(database, delete_from_daily_table, NULL, NULL, NULL);
	sqlite3_exec(database, delete_from_recordLog_table, NULL, NULL, NULL);
	sqlite3_exec(database, delete_from_sendLog_table, NULL, NULL, NULL);
	sqlite3_exec(database, delete_from_weekly_tabl, NULL, NULL, NULL);
}

- (id)init {
	DNSLogMethod
	self = [super init];
	NSString *appName = [self infoValueForKey:@"CFBundleName"];
	NSString *sqlFileName = [NSString stringWithFormat:@"%@.sql", appName];
	
	//
	// Open SQLite3 DB
	//
#if TARGET_OS_IPHONE | TARGET_IPHONE_SIMULATOR
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:sqlFileName];
#else
	NSArray *array = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,NSUserDomainMask,YES);
	NSString *NSApplicationSupportDirectoryPath = [array objectAtIndex:0];
	NSString *path = [NSApplicationSupportDirectoryPath stringByAppendingPathComponent:appName];
	
	// Make default path into home/libaray/application support/<Application name>/
	[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
	
	path = [path stringByAppendingPathComponent:sqlFileName];
#endif
	
	//
	// Open database
	//
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
		DNSLog(@"[MyController] initializeDatabase - OK");
		sqlite3_exec(database, "PRAGMA auto_vacuum=1", NULL, NULL, NULL);
		[self makeTables];
    }
	else {
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
	}
	
	return self;
}

@end

//
//  ITCLogParser.m
//  StoreSales
//
//  Created by sonson on 09/05/14.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ITCLogParser.h"
#import "SQLiteDBController.h"

// Tool
#import "NSData+AutoUnzip+AutoDecode.h"
#import "UICNSString+AutoDecoder.h"
#import "NSDate+DateExpression.h"

NSArray* new_4_0_column_itclog_names = nil;
NSArray* new_3_0_column_itclog_names = nil;
NSArray* new_column_itclog_names = nil;
NSArray* old_column_itclog_names = nil;

//
// Invaliables, used for identifier as SQLite3, recordLog
//
char *UICTypeString[] = {
	"ITCLogUnknown",
	"ITCLogDaily",
	"ITCLogWeekly",
	"ITCLogMonthly"
};

//
// Insert a record to send sales info to iPhone
//

void updateSendLog(NSDictionary* dict) {
	NSString* strResult = [dict objectForKey:@"prev_result"];
	NSString* strType = [dict objectForKey:@"prev_type"];
	int beginDateInteger = [[dict objectForKey:@"prev_beginDate"] intValue];
	int endDateInteger = [[dict objectForKey:@"prev_endDate"] intValue];
	
	if ([strResult isEqualToString:@"OK"]) {
	}
	else if ([strResult isEqualToString:@"AlreadyInserted"]) {
	}
	else if ([strResult isEqualToString:@"Error"]) {
		return;
	}
	
	ITCLogType type = ITCLogDaily;
	if ([strType isEqualToString:@"daily"]) {
		type = ITCLogDaily;
	}
	else if ([strType isEqualToString:@"weekly"]) {
		type = ITCLogWeekly;
	}
	else {
		type = ITCLogUnknown;
	}
	
	sqlite3 *database = [SQLiteDBController sharedInstance].database;
	
	// artist, beginDate, endDate, reportTimeType, vendorID
	int changes = 0;
	sqlite3_stmt *statement = NULL;
	char *sql = "insert into sendLog (reportTimeType, beginDate, endDate) values(?, ?, ?)";
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}
	else {
		sqlite3_bind_text(statement, 1, UICTypeString[type], strlen(UICTypeString[type]), SQLITE_TRANSIENT);
		sqlite3_bind_int(statement, 2, beginDateInteger);
		sqlite3_bind_int(statement, 3, endDateInteger);
		if (sqlite3_step(statement) == SQLITE_ROW) {
			changes = sqlite3_changes(database);
		}
	}
	sqlite3_finalize(statement);
}

@implementation ITCLogParser

#pragma mark -
#pragma mark Check if a file is iTunes connect sales log

+ (void)initialize {
	DNSLogMethod
	
	new_4_0_column_itclog_names = [[NSArray arrayWithObjects:
									@"Provider",
									@"Provider Country",
									@"SKU",
									@"Developer",
									@"Title",
									@"Version",
									@"Product Type Identifier",
									@"Units",
									@"Developer Proceeds",
									@"Begin Date",
									@"End Date",
									@"Customer Currency",
									@"Country Code",
									@"Currency of Proceeds",
									@"Apple Identifier",
									@"Customer Price",
									@"Promo Code",
									@"Parent Identifier",
									@"Subscription",
									@"Period",
									nil] retain];
	
	new_3_0_column_itclog_names = [[NSArray arrayWithObjects:
									@"Provider",
									@"Provider Country",
									@"SKU",
									@"Developer",
									@"Title",
									@"Version",
									@"Product Type Identifier",
									@"Units",
									@"Developer Proceeds",
									@"Begin Date",
									@"End Date",
									@"Customer Currency",
									@"Country Code",
									@"Currency of Proceeds",
									@"Apple Identifier",
									@"Customer Price",
									@"Promo Code",
									@"Parent Identifier",
								nil] retain];
	
	new_column_itclog_names = [[NSArray arrayWithObjects:
										 @"Provider",
										 @"Provider Country",
										 @"Vendor Identifier",
										 @"UPC",
										 @"ISRC",
										 @"Artist / Show",
										 @"Title / Episode / Season",
										 @"Label/Studio/Network",
										 @"Product Type Identifier",
										 @"Units",
										 @"Royalty Price",
										 @"Begin Date",
										 @"End Date",
										 @"Customer Currency",
										 @"Country Code",
										 @"Royalty Currency",
										 @"Preorder",
										 @"Season Pass",
										 @"ISAN",
										 @"Apple Identifier",
										 @"Customer Price",
										 @"CMA",
										 @"Asset/Content Flavor",
										 @"Vendor Offer Code",
										 @"Grid",
										 @"Promo Code",
										 @"Parent Identifier",
										 nil] retain];
	
	old_column_itclog_names = [[NSArray arrayWithObjects:
										@"Provider",
										@"Provider Country",
										@"Vendor Identifier",
										@"UPC",
										@"ISRC",
										@"Artist / Show",
										@"Title / Episode / Season",
										@"Label/Studio/Network",
										@"Product Type Identifier",
										@"Units",
										@"Royalty Price",
										@"Begin Date",
										@"End Date",
										@"Customer Currency",
										@"Country Code",
										@"Royalty Currency",
										@"Preorder",
										@"Season Pass",
										@"ISAN",
										@"Apple Identifier",
										@"Customer Price",
										@"CMA",
										@"Asset/Content Flavor",
										 nil] retain];
}

#pragma mark -
#pragma mark Method for inserting new data into database

//
// Insert incoming NSData into sales log and recordLog
//
+ (ITCDBResult)insertThisData:(NSData*)data targetDB:(sqlite3*)database beginDate:(NSDate**)beginDate endDate:(NSDate**)endDate logType:(ITCLogType*)type logVersion:(ITCLogVersion*)versionType {
	// DNSLogMethod

	//
	// Check whether this is iTunes coneect sales log data
	//
	if ([ITCLogParser isITCLog:data logType:type versionType:versionType beginDate:beginDate endDate:endDate]) {
		//
		// Check whether incomming data is already inserted into database
		//
		if (![ITCLogParser isArlreadInsertedDataWithLogType:*type beginDate:*beginDate endDate:*endDate targetDB:database]) {
			//
			// Insert incoming data
			//
			if ([ITCLogParser insertData:data logType:*type versionType:*versionType targetDB:database]) {
				DNSLog(@"OK");
				//
				// If inserting incoming data is successed, insert info which includes record type and bedin date and end date.
				// for later checking whether incomming data is already inserted into database
				//
				[ITCLogParser insertDataWithLogType:*type beginDate:*beginDate endDate:*endDate targetDB:database];
				return ITCDBReulstOK;
			}
			else {
				DNSLog(@"Insert failed");
				return ITCDBReulstUnkownError;
			}
		}
		else {
			// DNSLog(@"Already inserted");
			return ITCDBReulstErrorAlreadyInserted;
		}
	}
	DNSLog(@"Error");
	return ITCDBReulstUnkownError;
}

//
// Insert incoming NSData into sales log and recordLog
//
+ (ITCDBResult)insertThisData:(NSData*)data targetDB:(sqlite3*)database {
	// DNSLogMethod
	ITCLogType type = ITCLogUnknown;
	ITCLogVersion versionType = ITCLogVersion10;
	NSDate *beginDate = nil;
	NSDate *endDate = nil;
	return [ITCLogParser insertThisData:data targetDB:database beginDate:&beginDate endDate:&endDate logType:&type logVersion:&versionType];
}

+ (void)insertVendorIdentifier:(NSString*)vendorIdentifier		// 2
			titleEpisodeSeason:(NSString*)titleEpisodeSeason	// 6
		 productTypeIdentifier:(NSString*)productTypeIdentifier	// 8 Numeric
						 units:(NSString*)units					// 9 Numeric
				  royaltyPrice:(NSString*)royaltyPrice			// 10 Numeric float
					 beginDate:(NSString*)beginDate				// 11 Numeric
					   endDate:(NSString*)endDate				// 12 Numeric
			  customerCurrency:(NSString*)customerCurrency		// 13
				   countryCode:(NSString*)countryCode			// 14
			   royaltyCurrency:(NSString*)royaltyCurrency		// 15
			   appleIdentifier:(NSString*)appleIdentifier		// 19
				 customerPrice:(NSString*)customerPrice			// 20 Numeric float
			  parentIdentifier:(NSString*)parentIdentifier		// 27
			   sqliteStatement:(sqlite3_stmt*)statement			// SQLite3 statement
{
	//DNSLogMethod
	//	DNSLog(@"%@-%@", beginDate, endDate);
	int i = 1;
	//	sqlite3_bind_text(statement, 1, [dateIdentifier UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, i++, [vendorIdentifier UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, i++, [titleEpisodeSeason UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(statement, i++, [productTypeIdentifier intValue]);
	sqlite3_bind_int(statement, i++, [units intValue]);
	sqlite3_bind_double(statement, i++, [royaltyPrice floatValue]);
	NSDate *beginDateAsDate = [NSDate dateFromDateExpression:beginDate];
	sqlite3_bind_double(statement, i++, [beginDateAsDate timeIntervalSinceReferenceDate]);
	NSDate *endDateAsDate = [NSDate dateFromDateExpression:endDate];
	sqlite3_bind_double(statement, i++, [endDateAsDate timeIntervalSinceReferenceDate]);
	sqlite3_bind_text(statement, i++, [customerCurrency UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, i++, [countryCode UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, i++, [royaltyCurrency UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, i++, [appleIdentifier UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_double(statement, i++, [customerPrice floatValue]);
	if ([parentIdentifier isEqualToString:@" "])
		sqlite3_bind_text(statement, i++, NULL, -1, SQLITE_TRANSIENT);
	else
		sqlite3_bind_text(statement, i++, [parentIdentifier UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_step(statement);
}

+ (void)insertVendorIdentifier:(NSString*)vendorIdentifier		// 2
			titleEpisodeSeason:(NSString*)titleEpisodeSeason	// 6
		 productTypeIdentifier:(NSString*)productTypeIdentifier	// 8 Numeric
						 units:(NSString*)units					// 9 Numeric
				  royaltyPrice:(NSString*)royaltyPrice			// 10 Numeric float
					 beginDate:(NSString*)beginDate				// 11 Numeric
					   endDate:(NSString*)endDate				// 12 Numeric
			  customerCurrency:(NSString*)customerCurrency		// 13
				   countryCode:(NSString*)countryCode			// 14
			   royaltyCurrency:(NSString*)royaltyCurrency		// 15
			   appleIdentifier:(NSString*)appleIdentifier		// 19
				 customerPrice:(NSString*)customerPrice			// 20 Numeric float
withoutParentIdentifierStatement:(sqlite3_stmt*)statement			// SQLite3 statement
{
	//DNSLogMethod
	//	DNSLog(@"%@-%@", beginDate, endDate);
	int i = 1;
	//	sqlite3_bind_text(statement, 1, [dateIdentifier UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, i++, [vendorIdentifier UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, i++, [titleEpisodeSeason UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(statement, i++, [productTypeIdentifier intValue]);
	sqlite3_bind_int(statement, i++, [units intValue]);
	sqlite3_bind_double(statement, i++, [royaltyPrice floatValue]);
	NSDate *beginDateAsDate = [NSDate dateFromDateExpression:beginDate];
	sqlite3_bind_double(statement, i++, [beginDateAsDate timeIntervalSinceReferenceDate]);
	NSDate *endDateAsDate = [NSDate dateFromDateExpression:endDate];
	sqlite3_bind_double(statement, i++, [endDateAsDate timeIntervalSinceReferenceDate]);
	sqlite3_bind_text(statement, i++, [customerCurrency UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, i++, [countryCode UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, i++, [royaltyCurrency UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, i++, [appleIdentifier UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_double(statement, i++, [customerPrice floatValue]);
	sqlite3_step(statement);
}

+ (BOOL)insertData:(NSData*)data logType:(ITCLogType)type versionType:(ITCLogVersion)versionType targetDB:(sqlite3*)database {
	DNSLogMethod
	char *sql = NULL;
	char *sql_null = NULL;
	
	if (type == ITCLogDaily) {
		sql = "INSERT INTO daily (id, vendorIdentifier, titleEpisodeSeason, productTypeIdentifier, units, royaltyPrice, beginDate, endDate, customerCurrency, countryCode, royaltyCurrency, appleIdentifier,	customerPrice, parentIdentifier ) VALUES(NULL,?,?,?,?,?,?,?,?,?,?,?,?,?)";
		sql_null = "INSERT INTO daily (id, vendorIdentifier, titleEpisodeSeason, productTypeIdentifier, units, royaltyPrice, beginDate, endDate, customerCurrency, countryCode, royaltyCurrency, appleIdentifier,	customerPrice, parentIdentifier ) VALUES(NULL,?,?,?,?,?,?,?,?,?,?,?,?,NULL)";
	}
	else if (type == ITCLogWeekly) {
		sql = "INSERT INTO weekly (id, vendorIdentifier, titleEpisodeSeason, productTypeIdentifier, units, royaltyPrice, beginDate, endDate, customerCurrency, countryCode, royaltyCurrency, appleIdentifier,	customerPrice, parentIdentifier ) VALUES(NULL,?,?,?,?,?,?,?,?,?,?,?,?,?)";
		sql_null = "INSERT INTO weekly (id, vendorIdentifier, titleEpisodeSeason, productTypeIdentifier, units, royaltyPrice, beginDate, endDate, customerCurrency, countryCode, royaltyCurrency, appleIdentifier,	customerPrice, parentIdentifier ) VALUES(NULL,?,?,?,?,?,?,?,?,?,?,?,?,NULL)";
	}
	else {
		return NO;
	}
	
	// normal insert with parent identifier
	sqlite3_stmt *statement;
	sqlite3_exec( database, "BEGIN", NULL, NULL, NULL );
	if (sqlite3_prepare_v2( database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}
	
	// normal insert without parent identifier
	sqlite3_stmt *statement_null;
	if (sqlite3_prepare_v2( database, sql_null, -1, &statement_null, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}
	
	//NSString *text_data = [NSString stringAutoDecodeFromData:data];
	NSString *text_data = [data stringAutoUnzipAndDecoding];
	
	NSArray *lines = [text_data componentsSeparatedByString:@"\n"];
	NSArray *columnTable = nil;
	if (versionType == ITCLogVersion10) {
		columnTable= old_column_itclog_names;
	}
	else if (versionType == ITCLogVersion20) {
		columnTable = new_column_itclog_names;
	}
	else if (versionType == ITCLogVersion30) {
		columnTable = new_3_0_column_itclog_names;
	}
	else if (versionType == ITCLogVersion40) {
		columnTable = new_3_0_column_itclog_names;
	}
	else {
		sqlite3_finalize(statement);
		sqlite3_finalize(statement_null);
		sqlite3_exec(database, "COMMIT", NULL, NULL, NULL);
		sqlite3_exec(database, "END", NULL, NULL, NULL);
		return NO;
	}
	
	for (int i = 1; i < [lines count]; i++) {
		NSString *line = [lines objectAtIndex:i];
		NSArray *components = [line componentsSeparatedByString:@"\t"];
		if ([components count] >= 10 ) {
			if (versionType == ITCLogVersion10) {
				[ITCLogParser insertVendorIdentifier:[components objectAtIndex:[columnTable indexOfObject:@"Vendor Identifier"]]
								  titleEpisodeSeason:[components objectAtIndex:[columnTable indexOfObject:@"Title / Episode / Season"]]
							   productTypeIdentifier:[components objectAtIndex:[columnTable indexOfObject:@"Product Type Identifier"]]
											   units:[components objectAtIndex:[columnTable indexOfObject:@"Units"]]
										royaltyPrice:[components objectAtIndex:[columnTable indexOfObject:@"Royalty Price"]]
										   beginDate:[components objectAtIndex:[columnTable indexOfObject:@"Begin Date"]]
											 endDate:[components objectAtIndex:[columnTable indexOfObject:@"End Date"]]
									customerCurrency:[components objectAtIndex:[columnTable indexOfObject:@"Customer Currency"]]
										 countryCode:[components objectAtIndex:[columnTable indexOfObject:@"Country Code"]]
									 royaltyCurrency:[components objectAtIndex:[columnTable indexOfObject:@"Royalty Currency"]]
									 appleIdentifier:[components objectAtIndex:[columnTable indexOfObject:@"Apple Identifier"]]
									   customerPrice:[components objectAtIndex:[columnTable indexOfObject:@"Customer Price"]]
					withoutParentIdentifierStatement:statement_null];
			}
			else if (versionType == ITCLogVersion20) {
				DNSLog(@"(%@)", [components objectAtIndex:[columnTable indexOfObject:@"Parent Identifier"]]);
				[ITCLogParser insertVendorIdentifier:[components objectAtIndex:[columnTable indexOfObject:@"Vendor Identifier"]]
								  titleEpisodeSeason:[components objectAtIndex:[columnTable indexOfObject:@"Title / Episode / Season"]]
							   productTypeIdentifier:[components objectAtIndex:[columnTable indexOfObject:@"Product Type Identifier"]]
											   units:[components objectAtIndex:[columnTable indexOfObject:@"Units"]]
										royaltyPrice:[components objectAtIndex:[columnTable indexOfObject:@"Royalty Price"]]
										   beginDate:[components objectAtIndex:[columnTable indexOfObject:@"Begin Date"]]
											 endDate:[components objectAtIndex:[columnTable indexOfObject:@"End Date"]]
									customerCurrency:[components objectAtIndex:[columnTable indexOfObject:@"Customer Currency"]]
										 countryCode:[components objectAtIndex:[columnTable indexOfObject:@"Country Code"]]
									 royaltyCurrency:[components objectAtIndex:[columnTable indexOfObject:@"Royalty Currency"]]
									 appleIdentifier:[components objectAtIndex:[columnTable indexOfObject:@"Apple Identifier"]]
									   customerPrice:[components objectAtIndex:[columnTable indexOfObject:@"Customer Price"]]
									parentIdentifier:[components objectAtIndex:[columnTable indexOfObject:@"Parent Identifier"]]
									 sqliteStatement:statement];
			}
			else if (versionType == ITCLogVersion30) {
				DNSLog(@"(%@)", [components objectAtIndex:[columnTable indexOfObject:@"Parent Identifier"]]);
				[ITCLogParser insertVendorIdentifier:[components objectAtIndex:[columnTable indexOfObject:@"SKU"]]
								  titleEpisodeSeason:[components objectAtIndex:[columnTable indexOfObject:@"Title"]]
							   productTypeIdentifier:[components objectAtIndex:[columnTable indexOfObject:@"Product Type Identifier"]]
											   units:[components objectAtIndex:[columnTable indexOfObject:@"Units"]]
										royaltyPrice:[components objectAtIndex:[columnTable indexOfObject:@"Developer Proceeds"]]
										   beginDate:[components objectAtIndex:[columnTable indexOfObject:@"Begin Date"]]
											 endDate:[components objectAtIndex:[columnTable indexOfObject:@"End Date"]]
									customerCurrency:[components objectAtIndex:[columnTable indexOfObject:@"Customer Currency"]]
										 countryCode:[components objectAtIndex:[columnTable indexOfObject:@"Country Code"]]
									 royaltyCurrency:[components objectAtIndex:[columnTable indexOfObject:@"Currency of Proceeds"]]
									 appleIdentifier:[components objectAtIndex:[columnTable indexOfObject:@"Apple Identifier"]]
									   customerPrice:[components objectAtIndex:[columnTable indexOfObject:@"Customer Price"]]
									parentIdentifier:[components objectAtIndex:[columnTable indexOfObject:@"Parent Identifier"]]
									 sqliteStatement:statement];
			}
			else if (versionType == ITCLogVersion40) {		// as same as ITCLogVersion30
				DNSLog(@"(%@)", [components objectAtIndex:[columnTable indexOfObject:@"Parent Identifier"]]);
				[ITCLogParser insertVendorIdentifier:[components objectAtIndex:[columnTable indexOfObject:@"SKU"]]
								  titleEpisodeSeason:[components objectAtIndex:[columnTable indexOfObject:@"Title"]]
							   productTypeIdentifier:[components objectAtIndex:[columnTable indexOfObject:@"Product Type Identifier"]]
											   units:[components objectAtIndex:[columnTable indexOfObject:@"Units"]]
										royaltyPrice:[components objectAtIndex:[columnTable indexOfObject:@"Developer Proceeds"]]
										   beginDate:[components objectAtIndex:[columnTable indexOfObject:@"Begin Date"]]
											 endDate:[components objectAtIndex:[columnTable indexOfObject:@"End Date"]]
									customerCurrency:[components objectAtIndex:[columnTable indexOfObject:@"Customer Currency"]]
										 countryCode:[components objectAtIndex:[columnTable indexOfObject:@"Country Code"]]
									 royaltyCurrency:[components objectAtIndex:[columnTable indexOfObject:@"Currency of Proceeds"]]
									 appleIdentifier:[components objectAtIndex:[columnTable indexOfObject:@"Apple Identifier"]]
									   customerPrice:[components objectAtIndex:[columnTable indexOfObject:@"Customer Price"]]
									parentIdentifier:[components objectAtIndex:[columnTable indexOfObject:@"Parent Identifier"]]
									 sqliteStatement:statement];
			}
			sqlite3_reset(statement);
			sqlite3_reset(statement_null);
		}
	}
	sqlite3_finalize(statement);
	sqlite3_finalize(statement_null);
	sqlite3_exec(database, "COMMIT", NULL, NULL, NULL);
	sqlite3_exec(database, "END", NULL, NULL, NULL);
	//int result_row = sqlite3_changes(database);
	return YES;
}

+ (BOOL)insertDataWithLogType:(ITCLogType)type beginDate:(NSDate*)inputBeginDate endDate:(NSDate*)inputEndDate targetDB:(sqlite3*)database {
	DNSLogMethod
	// artist, beginDate, endDate, reportTimeType, vendorID
	int changes = 0;
	sqlite3_stmt *statement = NULL;
	char *sql = "insert into recordLog (reportTimeType, beginDate, endDate) values(?, ?, ?)";
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}
	else {
		sqlite3_bind_text(statement, 1, UICTypeString[type], strlen(UICTypeString[type]), SQLITE_TRANSIENT);
		sqlite3_bind_double(statement, 2, [inputBeginDate timeIntervalSinceReferenceDate]);
		sqlite3_bind_double(statement, 3, [inputEndDate timeIntervalSinceReferenceDate]);
		if (sqlite3_step(statement) == SQLITE_ROW) {
			changes = sqlite3_changes(database);
		}
	}
	sqlite3_finalize(statement);
	return (changes > 0);
}

+ (BOOL)isArlreadInsertedDataWithLogType:(ITCLogType)type beginDate:(NSDate*)inputBeginDate endDate:(NSDate*)inputEndDate targetDB:(sqlite3*)database {
	// DNSLogMethod
	// database;
	// artist, beginDate, endDate, reportTimeType, vendorID
	int result_count = 0;
	sqlite3_stmt *statement = NULL;
	char *sql = "select count(*) from recordLog where reportTimeType = ? and beginDate = ? and endDate = ?";
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}
	else {
		sqlite3_bind_text(statement, 1, UICTypeString[type], strlen(UICTypeString[type]), SQLITE_TRANSIENT);
		sqlite3_bind_double(statement, 2, [inputBeginDate timeIntervalSinceReferenceDate]);
		sqlite3_bind_double(statement, 3, [inputEndDate timeIntervalSinceReferenceDate]);
		if (sqlite3_step(statement) == SQLITE_ROW) {
			result_count = sqlite3_column_int(statement, 0);
		}
	}
	sqlite3_finalize(statement);
	return (result_count > 0);
}

#pragma mark -
#pragma mark Check whether data which will be sent is already sent

+ (BOOL)isArlreadSentDataWithLogType:(ITCLogType)type beginDate:(NSDate*)inputBeginDate endDate:(NSDate*)inputEndDate targetDB:(sqlite3*)database {
//	DNSLogMethod
	// artist, beginDate, endDate, reportTimeType, vendorID
	int result_count = 0;
	sqlite3_stmt *statement = NULL;
	char *sql = "select count(*) from sendLog where reportTimeType = ? and beginDate = ? and endDate = ?";
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}
	else {
		sqlite3_bind_text(statement, 1, UICTypeString[type], strlen(UICTypeString[type]), SQLITE_TRANSIENT);
		sqlite3_bind_double(statement, 2, [inputBeginDate timeIntervalSinceReferenceDate]);
		sqlite3_bind_double(statement, 3, [inputEndDate timeIntervalSinceReferenceDate]);
		if (sqlite3_step(statement) == SQLITE_ROW) {
			result_count = sqlite3_column_int(statement, 0);
		}
	}
	sqlite3_finalize(statement);
	return (result_count > 0);
}

#pragma mark -
#pragma mark Check whether NSData is a right iTunes connect log file.

+ (BOOL)isITCLog:(NSData*)inputData logType:(ITCLogType*)type versionType:(ITCLogVersion*)versionType beginDate:(NSDate**)outputBeginDate endDate:(NSDate**)outputEndDate {
	//
	// it's not text file
	//
	NSString *text_data = [inputData stringAutoUnzipAndDecoding];
	//NSString *text_data = [NSString stringAutoDecodeFromData:inputData];
	if (text_data == nil) {
		// Decode failed or binary file
		return NO;
	}

	//
	// it needs at least 2 lines
	//
	NSArray *lines = [text_data componentsSeparatedByString:@"\n"];
	NSString *headLine = [lines objectAtIndex:0];
	if ([lines count] < 2) {
		// lines is less
		return NO;
	}
	
	//
	// check head column's names, for check if it is iTunes connect log files.
	//
	NSArray *columns = [headLine componentsSeparatedByString:@"\t"];
	int columns_number = [columns count];
	if ([columns count] == [old_column_itclog_names count]) {
		if ([old_column_itclog_names isEqualToArray:columns]) {
			*versionType = ITCLogVersion10;
		}
	}
	else if ([columns count] == [new_column_itclog_names count]) {
		if ([new_column_itclog_names isEqualToArray:columns]) {
			*versionType = ITCLogVersion20;
		}
	}
	else if ([columns count] == [new_3_0_column_itclog_names count]) {
		if ([new_3_0_column_itclog_names isEqualToArray:columns]) {
			*versionType = ITCLogVersion30;
		}
	}
	else if ([columns count] == [new_4_0_column_itclog_names count]) {
		if ([new_4_0_column_itclog_names isEqualToArray:columns]) {
			*versionType = ITCLogVersion40;
		}
	}
	else {
		return NO;
	}
	
	//
	// Search column number of Begin Date and End Date.
	//	
	NSUInteger beginDateColumnNumber = [columns indexOfObject:@"Begin Date"];
	NSUInteger endDateColumnNumber = [columns indexOfObject:@"End Date"];

	//
	// Check daily or weekly or other?
	//
	*type = ITCLogUnknown;
	NSDate *beginDate = nil, *endDate = nil;
	for (int i = 1; i < [lines count]; i++) {
		NSArray *columns = [[lines objectAtIndex:i] componentsSeparatedByString:@"\t"];
		// DNSLog(@"%@", columns);
		// DNSLog(@"%d", [columns count]);
		// check size
		if ([columns count] >= columns_number) {
			NSString *beginDateString = [columns objectAtIndex:beginDateColumnNumber];
			NSString *endDateString = [columns objectAtIndex:endDateColumnNumber];
			beginDate = [NSDate dateFromDateExpression:beginDateString];
			endDate = [NSDate dateFromDateExpression:endDateString];
			
			NSTimeInterval k = [endDate timeIntervalSinceReferenceDate] - [beginDate timeIntervalSinceReferenceDate];
			if (k == 518400.000000) {
				// decide it's weekly data because interval between begin date and end date has 514800 sec.
				if (*type == ITCLogUnknown) {
					*type = ITCLogWeekly;
				}
				else if (*type != ITCLogWeekly) {
					return NO;
				}
			}
			if ([beginDate isEqualToDate:endDate] && [beginDate timeIntervalSinceReferenceDate] > 0 && [endDate timeIntervalSinceReferenceDate] > 0) {
			//	DNSLog(@"ITCLogDaily - %f,%f", [endDate timeIntervalSinceReferenceDate], [beginDate timeIntervalSinceReferenceDate]);
			//	DNSLog(@"            - %@,%@", [endDate description], [beginDate description]);
			//	DNSLog(@"            - %@,%@", beginDateString, endDateString);
				// decide it's weekly data because interval begin date is equal to end date
				if (*type == ITCLogUnknown) {
					*type = ITCLogDaily;
				}
				else if (*type != ITCLogDaily) {
					return NO;
				}
			}
		}
	}
	
	//
	// Check daily or weekly or other?
	//
	*outputBeginDate = beginDate;
	*outputEndDate = endDate;
	return (beginDate != nil) && (endDate != nil);
}

//
//
//
+ (BOOL)datesOfITCSalesLogFile:(NSData*)inputData beginDate:(NSDate**)outputBeginDate endDate:(NSDate**)outputEndDate {
	//
	// it's not text file
	//
	NSString *text_data = [inputData stringAutoUnzipAndDecoding];
	//NSString *text_data = [NSString stringAutoDecodeFromData:inputData];
	if (text_data == nil) {
		// Decode failed or binary file
		return NO;
	}
	
	//
	// it needs at least 2 lines
	//
	NSArray *lines = [text_data componentsSeparatedByString:@"\n"];
	NSString *headLine = [lines objectAtIndex:0];
	if ([lines count] < 2) {
		// lines is less
		return NO;
	}
	
	//
	// check head column's names, for check if it is iTunes connect log files.
	//
	NSArray *columns = [headLine componentsSeparatedByString:@"\t"];
	int columns_number = [columns count];
	if ([columns count] == [old_column_itclog_names count]) {
		if ([old_column_itclog_names isEqualToArray:columns]) {
		}
	}
	else if ([columns count] == [new_column_itclog_names count]) {
		if ([new_column_itclog_names isEqualToArray:columns]) {
		}
	}
	else {
		return NO;
	}
	
	//
	// Search column number of Begin Date and End Date.
	//	
	NSUInteger beginDateColumnNumber = [columns indexOfObject:@"Begin Date"];
	NSUInteger endDateColumnNumber = [columns indexOfObject:@"End Date"];
	
	//
	// Check daily or weekly or other?
	//
	NSDate *beginDate = nil;
	NSDate *endDate = nil;
	for (int i = 1; i < [lines count]; i++) {
		NSArray *columns = [[lines objectAtIndex:i] componentsSeparatedByString:@"\t"];
		// check size
		if ([columns count] >= columns_number) {
			NSString *beginDateString = [columns objectAtIndex:beginDateColumnNumber];
			NSString *endDateString = [columns objectAtIndex:endDateColumnNumber];
			NSDate *currentBeginDate = [NSDate dateFromDateExpression:beginDateString];
			NSDate *currentEndDate = [NSDate dateFromDateExpression:endDateString];
			if (beginDate != nil && endDate != nil) {
				if ([beginDate isEqualToDate:currentBeginDate] && [endDate isEqualToDate:currentEndDate]) {
				}
				else {
					return NO;
				}
			}
			else {
				beginDate = currentBeginDate;
				endDate = currentEndDate;
			}
		}
	}
	
	*outputBeginDate = beginDate;
	*outputEndDate = endDate;
	return YES;
}

#pragma mark -
#pragma mark dealloc

- (void) dealloc {
	DNSLogMethod
	[super dealloc];
}

@end

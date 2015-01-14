//
//  ITCLogParser.h
//  StoreSales
//
//  Created by sonson on 09/05/14.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

// enumerator, identifier for term of iTunes connect sales log file
typedef enum {
	ITCLogUnknown,
	ITCLogDaily,
	ITCLogWeekly,
	ITCLogMonthly,
}ITCLogType;

// iTunes connect sales log file format version
typedef enum {
	ITCLogVersion10,	// iTunes connect version 1.0
	ITCLogVersion20,	// ver2.0 since 2008.11?
	ITCLogVersion30,	// ver3.0 since 2010.09?
	ITCLogVersion40,	// ver4.0 since 2011.02?
}ITCLogVersion;

// Inserting result enum.
typedef enum {
	ITCDBReulstOK = 0,
	ITCDBReulstUnkownError = 1,
	ITCDBReulstErrorAlreadyInserted = 2,
}ITCDBResult;

void updateSendLog(NSDictionary* dict);

#pragma mark -
#pragma mark Class

@interface ITCLogParser : NSObject {
}

#pragma mark -
#pragma mark Check if a file is iTunes connect sales log

+ (void)initialize;

#pragma mark -
#pragma mark Method for inserting new data into database

//
// Insert incoming NSData into sales log and recordLog
//
+ (ITCDBResult)insertThisData:(NSData*)data targetDB:(sqlite3*)database beginDate:(NSDate**)beginDate endDate:(NSDate**)endDate logType:(ITCLogType*)type logVersion:(ITCLogVersion*)versionType;

//
// Insert incoming NSData into sales log and recordLog
//
+ (ITCDBResult)insertThisData:(NSData*)data targetDB:(sqlite3*)database;

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
			   sqliteStatement:(sqlite3_stmt*)statement;		// SQLite3 statement
+ (BOOL)insertData:(NSData*)data logType:(ITCLogType)type versionType:(ITCLogVersion)versionType targetDB:(sqlite3*)database;
+ (BOOL)insertDataWithLogType:(ITCLogType)type beginDate:(NSDate*)inputBeginDate endDate:(NSDate*)inputEndDate targetDB:(sqlite3*)database;
+ (BOOL)isArlreadInsertedDataWithLogType:(ITCLogType)type beginDate:(NSDate*)inputBeginDate endDate:(NSDate*)inputEndDate targetDB:(sqlite3*)database;

#pragma mark -
#pragma mark Check whether data which will be sent is already sent
+ (BOOL)isArlreadSentDataWithLogType:(ITCLogType)type beginDate:(NSDate*)inputBeginDate endDate:(NSDate*)inputEndDate targetDB:(sqlite3*)database;

#pragma mark -
#pragma mark Check whether NSData is a right iTunes connect log file.
+ (BOOL)isITCLog:(NSData*)inputData logType:(ITCLogType*)type versionType:(ITCLogVersion*)versionType beginDate:(NSDate**)outputBeginDate endDate:(NSDate**)outputEndDate;

+ (BOOL)datesOfITCSalesLogFile:(NSData*)inputData beginDate:(NSDate**)outputBeginDate endDate:(NSDate**)outputEndDate;
@end

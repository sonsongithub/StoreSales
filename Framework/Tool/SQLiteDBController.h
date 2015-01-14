//
//  SQLiteDBController.h
//  StoreSales
//
//  Created by sonson on 09/05/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface SQLiteDBController : NSObject {
	sqlite3		*database;
}
+ (SQLiteDBController*)sharedInstance;
- (void)makeTables;
- (void)deleteAllRecordFromAllTables;
@property (nonatomic, readonly) sqlite3* database;

#pragma mark -
#pragma mark Record count
- (int)getSendLog;
- (int)getRecordLogOfDailyLog;
- (int)getRecordLogOfWeeklyLog;
- (void)getRecordLogOfDailyLog:(int*)dailyLog weeklyLog:(int*)weeklyLog;

@end

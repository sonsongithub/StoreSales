//
//  YAHCurrencyTool.h
//  StoreSales
//
//  Created by sonson on 09/05/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface YAHCurrencyTool : NSObject {
}
+ (NSString *)baseCurrencyDescription:(NSString*)currencyCode;
+ (float)currencyRate:(NSString*)currencyCode targetDatabase:(sqlite3*)database;
+ (void)update:(NSArray*)rateStrings targetDatabase:(sqlite3*)database;
+ (void)updateCurrencyTable:(NSString*)csv targetDatabase:(sqlite3*)database;
+ (NSURL*)URLYahooData;
+ (void)readCurrencyInfoPlistIntoDatabase:(sqlite3*)database;
@end

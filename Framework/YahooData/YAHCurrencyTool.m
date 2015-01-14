//
//  YAHCurrencyTool.m
//  StoreSales
//
//  Created by sonson on 09/05/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "YAHCurrencyTool.h"

NSString* BaseYahooDataURL = nil;
NSArray* CurrencyList = nil;

@implementation YAHCurrencyTool

+ (void)initialize {
	if (BaseYahooDataURL == nil) {
		BaseYahooDataURL = @"http://quote.yahoo.com/d/quotes.csv?s=";
	}
	if (CurrencyList == nil) {
		CurrencyList = [[NSArray arrayWithObjects:
						 @"AUD", @"BHD", @"THB", @"BND", 
						 @"CLP", @"DKK", @"EUR", @"HUF", @"HKD", @"ISK", @"CAD", 
						 @"QAR", @"KWD", @"MYR", @"MTL", @"MUR", @"MXN", 
						 @"NPR", @"TWD", @"NZD", @"NOK", @"PKR", @"GBP", 
						 @"ZAR", @"BRL", @"CNY", @"OMR", @"IDR", @"RUB", 
						 @"SAR", @"ILS", @"SEK", @"CHF", @"SGD", @"SKK", 
						 @"LKR", @"KRW", @"KZT", @"CZK", @"AED", @"JPY", 
						 @"CYP", @"INR", nil] retain];
	}
}

+ (NSString *)baseCurrencyDescription:(NSString*)currencyCode {
	if ([currencyCode isEqual:@"EUR"])
		return @"€";
	if ([currencyCode isEqual:@"USD"])
		return @"$";
	if ([currencyCode isEqual:@"JPY"])
		return @"¥";
	if ([currencyCode isEqual:@"GBP"])
		return @"£";
	return currencyCode;
}

+ (float)currencyRate:(NSString*)currencyCode targetDatabase:(sqlite3*)database {
	char *sql = "select rate from currencyTableUSD where code = ?";
	float rate = 1.0;
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database ));
	}
	else {
		sqlite3_bind_text(statement, 1, [currencyCode UTF8String], -1, SQLITE_TRANSIENT);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			rate = sqlite3_column_double(statement, 0);
			break;
		}
	}
	sqlite3_finalize(statement);
	return rate;
}

+ (void)readCurrencyInfoPlistIntoDatabase:(sqlite3*)database {
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"currency.plist" ofType:nil];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		NSData *data  = [NSData dataWithContentsOfFile:path];
		NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		NSArray *array = [NSArray arrayWithArray:[decoder decodeObjectForKey:@"currency"]];
		[decoder finishDecoding];
		[decoder release];
		
		if ([array count]) {
		}
		
		sqlite3_exec( database, "BEGIN", NULL, NULL, NULL );
		sqlite3_exec( database, "delete from currencyTableUSD", NULL, NULL, NULL );
		char *sql = "insert INTO currencyTableUSD (rate, code) VALUES(?,?)";
		sqlite3_stmt *statement;	
		if (sqlite3_prepare_v2( database, sql, -1, &statement, NULL) != SQLITE_OK) {
			DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
		}
		
		for (NSDictionary *info in array) {
			
			NSString *currencyCode = [info objectForKey:@"code"];
			NSNumber *rate = [info objectForKey:@"rate"];
			sqlite3_bind_double(statement, 1, [rate floatValue]);
			sqlite3_bind_text(statement, 2, [currencyCode UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_step(statement);		
			sqlite3_reset(statement);
		}
		
		sqlite3_finalize(statement);
		sqlite3_exec(database, "COMMIT", NULL, NULL, NULL );
		sqlite3_exec(database, "END", NULL, NULL, NULL );
	}
}

+ (void)writeCurrencyInfoPlistFromDatabase:(sqlite3*)database {
	char *sql = "select code, rate from currencyTableUSD";
	
	NSMutableArray *array = [NSMutableArray array];
	
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database ));
	}
	else {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			char *c_code = (char *)sqlite3_column_text(statement, 0);
			float f_rate = sqlite3_column_double(statement, 1);
			
			if (c_code != NULL && f_rate > 0) {
				NSString *code = [NSString stringWithUTF8String:c_code];
				NSNumber *rate = [NSNumber numberWithFloat:f_rate];
				
				NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:code, @"code", rate, @"rate", nil];
				[array addObject:info];
				
			}
		}
	}
	
	NSMutableData *data = [NSMutableData data];
	NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"currency.plist"];
	
	[encoder encodeObject:array forKey:@"currency"];
	[encoder finishEncoding];
	[data writeToFile:path atomically:NO];
	[encoder release];
	
	sqlite3_finalize(statement);
}

+ (void)update:(NSArray*)rateStrings targetDatabase:(sqlite3*)database {
	sqlite3_exec( database, "BEGIN", NULL, NULL, NULL );
	sqlite3_exec( database, "delete from currencyTableUSD", NULL, NULL, NULL );
	char *sql = "insert INTO currencyTableUSD (rate, code) VALUES(?,?)";
	sqlite3_stmt *statement;	
	if (sqlite3_prepare_v2( database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}
	for (int i = 0; i < [CurrencyList count]; i++) {
		NSString *currencyCode = [CurrencyList objectAtIndex:i];
		NSString *rate = [rateStrings objectAtIndex:i];
		sqlite3_bind_double(statement, 1, [rate floatValue]);
		sqlite3_bind_text(statement, 2, [currencyCode UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_step(statement);		
		sqlite3_reset(statement);
	}
	
	// for USD
	sqlite3_bind_double(statement, 1, 1.0);
	sqlite3_bind_text(statement, 2, "USD", -1, SQLITE_TRANSIENT);
	sqlite3_step(statement);		
	sqlite3_reset(statement);
	
	sqlite3_finalize(statement);
	sqlite3_exec(database, "COMMIT", NULL, NULL, NULL );
	sqlite3_exec(database, "END", NULL, NULL, NULL );
	
#if TARGET_IPHONE_SIMULATOR
	[YAHCurrencyTool writeCurrencyInfoPlistFromDatabase:database];
#endif
}

+ (void)updateCurrencyTable:(NSString*)csv targetDatabase:(sqlite3*)database {
//	DNSLogMethod
	DNSLog(@"%@", csv);
	NSArray *lines = [csv componentsSeparatedByString:@"\n"];
	NSMutableArray *rateStrings = [NSMutableArray array];
	for (NSString *line in lines) {
		if ([line length] > 0) {
			[rateStrings addObject:line];
		}
	}
	if ([rateStrings count] != [CurrencyList count]) {
		DNSLog(@"Maybe, error");
#if TARGET_OS_IPHONE | TARGET_IPHONE_SIMULATOR
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
														message:NSLocalizedString(@"Please retry to reload info later.", nil)
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
		[alert show];
		[alert release];
#endif
		return;
	}
	[YAHCurrencyTool update:rateStrings targetDatabase:database];
}

+ (NSURL*)URLYahooData {
	NSMutableString* urlString = [NSMutableString stringWithString:BaseYahooDataURL];
	for (NSString* currencyCode in CurrencyList) {
		[urlString appendFormat:@"USD%@=X+", currencyCode];
	}
	if ([urlString characterAtIndex:[urlString length] - 1] == '+') {
		[urlString deleteCharactersInRange:NSMakeRange([urlString length] - 1, 1)];
	}
	[urlString appendString:@"&f=l1"];
	return [NSURL URLWithString:urlString];
}

@end

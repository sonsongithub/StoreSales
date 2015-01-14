//
//  FlagController.m
//  StoreSales
//
//  Created by sonson on 09/03/03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CountryInfo.h"
#import "SQLiteDBController.h"

NSDictionary *sharedCountryInfoDictionary = nil;

@implementation CountryInfo

@synthesize flagImage;
@synthesize name;
@synthesize countryCode;
@synthesize color;

#pragma mark -
#pragma mark Class method

+ (NSDictionary*)sharedCountryInfoDictionary {
	if (sharedCountryInfoDictionary == nil) {
		sharedCountryInfoDictionary = [[self flagDictionary] retain];
	}
	return sharedCountryInfoDictionary;
}

+ (NSDictionary*)sharedCountryInfoDictionaryWithRevoling {
	[sharedCountryInfoDictionary release];
	sharedCountryInfoDictionary = [[self flagDictionary] retain];
	return sharedCountryInfoDictionary;
}

+ (NSMutableArray*)availableCountryCodes {
	NSMutableArray* countryCodes = [NSMutableArray array];
	// char *sql = "select distinct countryCode from weekly, daily";
	char *sql = "select distinct countryCode from (SELECT countryCode FROM weekly UNION ALL SELECT countryCode FROM daily);";
	sqlite3 *database = [SQLiteDBController sharedInstance].database;
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}	
	else {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			char *countryCode = (char*)sqlite3_column_text(statement, 0);
			if (countryCode != NULL) {
				[countryCodes addObject:[NSString stringWithUTF8String:countryCode]];
			}
		}
	}
	sqlite3_finalize( statement );
	return countryCodes;
}

+ (void)refreshCountryColors {
#if TARGET_OS_IPHONE | TARGET_IPHONE_SIMULATOR
	NSMutableDictionary *dict = UIAppDelegate.countryInfoDict;
	float hue = 0.3;
	float hueStep = 1.0 / (float)[[dict allKeys] count];
	for (NSString* key in [dict allKeys]) {
		CountryInfo* info = [dict objectForKey:key];
		info.color = [UIColor colorWithHue:hue saturation:0.75 brightness:0.75 alpha:1.0];
		hue += hueStep;
	}
#else
#endif
}

+ (NSMutableDictionary*)flagDictionary {
	NSMutableArray *countryCodes = [CountryInfo availableCountryCodes];
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[countryCodes count]];

	NSLocale *locale = [NSLocale systemLocale];
	
	for (NSString* countryCode in countryCodes) {
		CountryInfo *info = [[CountryInfo alloc] init];
		NSString *imageName = [NSString stringWithFormat:@"%@.png", countryCode];
#if TARGET_OS_IPHONE | TARGET_IPHONE_SIMULATOR
		info.flagImage = [UIImage imageNamed:imageName];
#else
		info.flagImage = [NSImage imageNamed:imageName];
#endif
		info.countryCode = countryCode;
		
		NSString* output= [locale displayNameForKey:NSLocaleIdentifier value:[NSString stringWithFormat:@"en_%@", countryCode]];
		NSRange range = [output rangeOfString:@"("];
		
		if (range.location != NSNotFound) {
			info.name = [output substringWithRange:NSMakeRange(range.location+1, [output length] - range.location - 2)];
		}
		else {
			info.name = countryCode;
		}
		if (info.flagImage != nil) {
		}
		else {
			DNSLog(@"%@'s flag not found", countryCode);
		}
//		DNSLog(@"%@", info.name);
		[dictionary setObject:info forKey:countryCode];
		[info release];
	}
	return dictionary;
}

+ (CountryInfo*)otherCountries {
	CountryInfo *info = [[CountryInfo alloc] init];
#if TARGET_OS_IPHONE | TARGET_IPHONE_SIMULATOR
	info.color = [UIColor grayColor];
	info.flagImage = [UIImage imageNamed:@"other.png"];
#else
	info.color = [NSColor grayColor];
	info.flagImage = [NSImage imageNamed:@"other.png"];
#endif
	return [info autorelease];
}

- (NSString*)description {
	return [NSString stringWithFormat:@"%@:%@", name, countryCode];
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[flagImage release];
	[name release];
	[color release];
	[countryCode release];
	[super dealloc];
}

@end

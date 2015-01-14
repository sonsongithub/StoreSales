//
//  Application.m
//  StoreSales
//
//  Created by sonson on 09/02/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ApplicationInfo.h"
#import "SQLiteDBController.h"
#import "ITSTool.h"

#if TARGET_OS_IPHONE | TARGET_IPHONE_SIMULATOR
UIImage *UnknownAppIcon = nil;
#else
NSImage *UnknownAppIcon = nil;
#endif

ApplicationInfo *UnknownApplicationInfo = nil;

NSDictionary *sharedApplicationInfoDictionary = nil;

@implementation ApplicationInfo

@synthesize icon;
@synthesize name;
@synthesize appleIdentifierString;
@synthesize parentIdentifierString;
@synthesize appleIdentifier;
@synthesize color;

#pragma mark -
#pragma mark Class method

+ (ApplicationInfo*)unknownApplicationInfo {
	ApplicationInfo* info = [[[ApplicationInfo alloc] init] autorelease];
	info.icon = UnknownAppIcon;
	return info;
}

+ (NSDictionary*)sharedApplicationInfoDictionary {
	if (sharedApplicationInfoDictionary == nil) {
		sharedApplicationInfoDictionary = [[self applicationInfoADict] retain];
	}
	return sharedApplicationInfoDictionary;
}

+ (NSDictionary*)sharedApplicationInfoDictionaryWithRevoling {
	[sharedApplicationInfoDictionary release];
	sharedApplicationInfoDictionary = [[self applicationInfoADict] retain];
	return sharedApplicationInfoDictionary;
}

+ (void)refreshApplicationColors {
#if TARGET_OS_IPHONE | TARGET_IPHONE_SIMULATOR
	NSMutableDictionary *dict = UIAppDelegate.applicationInfoDict;
	float hue = 0.3;
	float hueStep = 1.0 / (float)[[dict allKeys] count];
	for (NSString* key in [dict allKeys]) {
		ApplicationInfo* info = [dict objectForKey:key];
		info.color = [UIColor colorWithHue:hue saturation:0.75 brightness:0.75 alpha:1.0];
		hue += hueStep;
	}
#else
#endif
}

+ (NSMutableDictionary*)applicationInfoADict {
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	char *sql = "select name, icon, appleIdentifier from application order by appleIdentifier";
	sqlite3 *database = [SQLiteDBController sharedInstance].database;
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}	
	else {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			char *name = (char*)sqlite3_column_text(statement, 0);
			char *icon = (char*)sqlite3_column_blob(statement, 1);
			int icon_bytes = sqlite3_column_bytes(statement, 1);
			int appleIdentifier = sqlite3_column_int(statement, 2);
			if (name != NULL && icon != NULL && icon_bytes > 0) {
				ApplicationInfo* info = [[ApplicationInfo alloc] init];
				info.appleIdentifier = appleIdentifier;
				NSData *iconData = [NSData dataWithBytes:icon length:icon_bytes];
#if TARGET_OS_IPHONE | TARGET_IPHONE_SIMULATOR
				UIImage *image = [UIImage imageWithData:iconData];
#else
				NSImage *image =[[[NSImage alloc] initWithData:iconData] autorelease];
#endif
				info.name = [NSString stringWithUTF8String:name];
				info.icon = image;
				[dict setObject:info forKey:[NSString stringWithFormat:@"%d", appleIdentifier]];
				[info release];
			}
		}
	}
	sqlite3_finalize( statement );
	
	// addons
	NSArray *addons = [ITSTool addOnnIdentifiersFromTargetDatabase:database];
	for (NSDictionary *addon in addons) {
		NSString *appleIdentifier = [addon objectForKey:@"appleIdentifier"];
		NSString *name = [addon objectForKey:@"name"];
		NSString *parentIdentifier = [addon objectForKey:@"parentIdentifier"];
		NSString *parentAppleIdentifier = [addon objectForKey:@"parentAppleIdentifier"];
		ApplicationInfo* info = [[ApplicationInfo alloc] init];
		info.appleIdentifierString = appleIdentifier;
		info.appleIdentifier = [appleIdentifier intValue];
		info.name = name;
		info.parentIdentifierString = parentIdentifier;
		
		ApplicationInfo *parentAppInfo = [dict objectForKey:parentAppleIdentifier];
		info.icon = parentAppInfo.icon; 
		
		[dict setObject:info forKey:appleIdentifier];
		[info release];
	}
	
	// for debug
//	for (NSString *key in [dict allKeys]) {
//		ApplicationInfo *info = [dict objectForKey:key];
//		DNSLog(@"%@", info);
//	}
	
	return dict;
}

+ (NSMutableArray*)applicationInfoArray {
	NSMutableArray* array = [NSMutableArray array];
	char *sql = "select name, icon, appleIdentifier from application order by appleIdentifier";
	sqlite3_stmt *statement;
	sqlite3 *database = [SQLiteDBController sharedInstance].database;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}	
	else {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			char *name = (char*)sqlite3_column_text(statement, 0);
			char *icon = (char*)sqlite3_column_blob(statement, 1);
			int icon_bytes = sqlite3_column_bytes(statement, 1);
			int appleIdentifier = sqlite3_column_int(statement, 2);
			if (name != NULL && icon != NULL && icon_bytes > 0) {
				ApplicationInfo* info = [[ApplicationInfo alloc] init];
				info.appleIdentifier = appleIdentifier;
				info.name = [NSString stringWithUTF8String:name];
				NSData *iconData = [NSData dataWithBytes:icon length:icon_bytes];
#if TARGET_OS_IPHONE | TARGET_IPHONE_SIMULATOR
				info.icon = [UIImage imageWithData:iconData];
#else
				info.icon = [[[NSImage alloc] initWithData:iconData] autorelease];
#endif
				[array addObject:info];
				[info release];
			}
		}
	}
	sqlite3_finalize( statement );
	return array;
}

+ (void)initialize {
	if (UnknownAppIcon == nil) {
#if TARGET_OS_IPHONE | TARGET_IPHONE_SIMULATOR
		UnknownAppIcon = [[UIImage imageNamed:@"unknownApp.png"] retain];
#else
		UnknownAppIcon = [[NSImage imageNamed:@"unknownApp.png"] retain];
#endif
	}
}

// for make dummy data
+ (void)updateDummyIcon {
	char *sql = "update application set icon = ?";
	sqlite3_stmt *statement;
	sqlite3 *database = [SQLiteDBController sharedInstance].database;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}	
	else {
#if TARGET_OS_IPHONE | TARGET_IPHONE_SIMULATOR
		NSData *data = UIImagePNGRepresentation(UnknownAppIcon);
#else
		NSData *data = nil;
#endif
		sqlite3_bind_blob(statement, 1, [data bytes], [data length], SQLITE_TRANSIENT);
		if (sqlite3_step(statement) != SQLITE_ERROR) {
		}
	}
	sqlite3_finalize( statement );
}

#pragma mark -
#pragma mark dealloc

- (NSString*)description {
	return [NSString stringWithFormat:@"%@:%d", name, appleIdentifier];
}

- (id)init {
	self = [super init];
	self.icon = UnknownAppIcon;
	return self;
}

- (void)dealloc {
	[color release];
	[appleIdentifierString release];
	[parentIdentifierString release];
	[icon release];
	[name release];
	[super dealloc];
}

@end

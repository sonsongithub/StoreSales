//
//  ITSTool.m
//  StoreSales
//
//  Created by sonson on 09/05/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ITSTool.h"

@implementation ITSTool

+ (NSArray*)appleIdentifiersFromTargetDatabase:(sqlite3*)database {
	DNSLogMethod
	char *sql = "select appleIdentifier, parentIdentifier from (select distinct appleIdentifier, parentIdentifier from daily union select distinct appleIdentifier, parentIdentifier from weekly);";
	sqlite3_stmt *statement;
	NSMutableArray* appleIdentifiers = [NSMutableArray array];
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database ));
	}	
	else {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			char *tag_source = (char *)sqlite3_column_text(statement, 0);
			char *parentIdentifier = (char *)sqlite3_column_text(statement, 1);
			if (tag_source != NULL && parentIdentifier == NULL) {
				DNSLog(@"%s", tag_source);
				[appleIdentifiers addObject:[NSString stringWithUTF8String:tag_source]];
			}
		}
	}
	sqlite3_finalize( statement );
	return appleIdentifiers;
}

+ (NSString*)parentAppleIdentifierFromTargetDatabase:(sqlite3*)database withVendorIdentifier:(NSString*)vendorIdentifier {
	char *sql = "select appleIdentifier from application where vendorIdentifier = ?;";
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database ));
	}	
	else {
		sqlite3_bind_text(statement, 1, [vendorIdentifier UTF8String], -1, SQLITE_TRANSIENT);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			char *appleIdentifier = (char *)sqlite3_column_text(statement, 0);
			if (appleIdentifier != NULL) {
				NSString *p = [NSString stringWithUTF8String:appleIdentifier];
				sqlite3_finalize( statement );
				return p;
			}
		}
	}
	sqlite3_finalize( statement );
	return nil;
}

+ (NSArray*)addOnnIdentifiersFromTargetDatabase:(sqlite3*)database {
	DNSLogMethod
	char *sql = "select distinct appleIdentifier, titleEpisodeSeason, parentIdentifier from (select distinct parentIdentifier, titleEpisodeSeason, appleIdentifier from daily where parentIdentifier != '' union select distinct parentIdentifier, titleEpisodeSeason, appleIdentifier from weekly where parentIdentifier != '');";
	sqlite3_stmt *statement;
	NSMutableArray* appleIdentifiers = [NSMutableArray array];
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database ));
	}	
	else {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			char *c_appleIdentifier = (char *)sqlite3_column_text(statement, 0);
			char *c_name = (char *)sqlite3_column_text(statement, 1);
			char *c_parentIdentifier = (char *)sqlite3_column_text(statement, 2);
			if (c_appleIdentifier != NULL && c_name  != NULL && c_parentIdentifier != NULL) {
				NSString *parentIdentifier = [NSString stringWithUTF8String:c_parentIdentifier];
				NSString *appleIdentifier = [NSString stringWithUTF8String:c_appleIdentifier];
				NSString *name = [NSString stringWithUTF8String:c_name];
				NSString *parentAppleIdentifier = [ITSTool parentAppleIdentifierFromTargetDatabase:database withVendorIdentifier:parentIdentifier];
				
				NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
									  appleIdentifier, @"appleIdentifier",
									  name,				@"name",
									  parentIdentifier, @"parentIdentifier",
									  parentAppleIdentifier, @"parentAppleIdentifier",
									  nil];
				[appleIdentifiers addObject:dict];
			}
		}
	}
	sqlite3_finalize( statement );
	return appleIdentifiers;
}

//+ (NSArray*)addOnnIdentifiersFromTargetDatabase:(sqlite3*)database {
//	DNSLogMethod
//	char *sql = "select appleIdentifier, titleEpisodeSeason, parentIdentifier from (select distinct parentIdentifier, titleEpisodeSeason, appleIdentifier from daily union select distinct parentIdentifier, titleEpisodeSeason, appleIdentifier from weekly);";
//	sqlite3_stmt *statement;
//	NSMutableArray* appleIdentifiers = [NSMutableArray array];
//	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
//		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database ));
//	}	
//	else {
//		while (sqlite3_step(statement) == SQLITE_ROW) {
//			char *appleIdentifier = (char *)sqlite3_column_text(statement, 0);
//			char *name = (char *)sqlite3_column_text(statement, 1);
//			char *parentIdentifier = (char *)sqlite3_column_text(statement, 2);
//			if (appleIdentifier != NULL && name != NULL && parentIdentifier != NULL) {
//				NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//									  [NSString stringWithUTF8String:appleIdentifier], @"appleIdentifier",
//									  [NSString stringWithUTF8String:name], @"name",
//									  [NSString stringWithUTF8String:parentIdentifier], @"parentIdentifier",
//									  nil];
//				[appleIdentifiers addObject:dict];
//			}
//		}
//	}
//	sqlite3_finalize( statement );
//	return appleIdentifiers;
//}

+ (NSDictionary*)newApplicationNameAndVendorIdentifierWithAppleID:(NSString*)appleIdentifier targetDatabase:(sqlite3*)database {
	char *sql = "select titleEpisodeSeason, vendorIdentifier from daily where appleIdentifier = ? order by endDate limit 0,1";
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database ));
	}	
	else {
		sqlite3_bind_text(statement, 1, [appleIdentifier UTF8String], -1, SQLITE_TRANSIENT);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			char *titleEpisodeSeason = (char*)sqlite3_column_text(statement, 0);
			char *vendorIdentifier = (char*)sqlite3_column_text(statement, 1);
			if (titleEpisodeSeason != NULL && vendorIdentifier != NULL) {
				NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithUTF8String:titleEpisodeSeason], @"name",
									  [NSString stringWithUTF8String:vendorIdentifier], @"vendorIdentifier", nil];
				sqlite3_finalize( statement );
				return dict;
			}
		}
	}
	sqlite3_finalize( statement );
	return nil;
}

+ (BOOL)updateApplicationWithAppleID:(NSString*)appleIdentifier name:(NSString*)name vendorIdentifier:(NSString*)vendorIdentifier icon:(NSData*)icon targetDatabase:(sqlite3*)database {
	char *sql = "update application set name = ?, icon = ? where appleIdentifier = ?";
	sqlite3_stmt *statement;
	BOOL result = NO;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database ));
	}	
	else {
		sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_blob(statement, 2, [icon bytes], [icon length], SQLITE_TRANSIENT);
		sqlite3_bind_int(statement, 3, [appleIdentifier intValue]);
		if (sqlite3_step(statement) != SQLITE_ERROR) {
			if (sqlite3_changes(database) > 0) {
				result = YES;
			}
		}
	}
	sqlite3_finalize( statement );
	return result;
}

+ (BOOL)insertApplicationWithAppleID:(NSString*)appleIdentifier name:(NSString*)name vendorIdentifier:(NSString*)vendorIdentifier icon:(NSData*)icon targetDatabase:(sqlite3*)database {
	char *sql = "insert into application (appleIdentifier, vendorIdentifier, name, icon) values(?, ?, ?, ?)";
	sqlite3_stmt *statement;
	BOOL result = NO;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database ));
	}	
	else {
		sqlite3_bind_int(statement, 1, [appleIdentifier intValue]);
		sqlite3_bind_text(statement, 2, [vendorIdentifier UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 3, [name UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_blob(statement, 4, [icon bytes], [icon length], SQLITE_TRANSIENT);
		if (sqlite3_step(statement) != SQLITE_ERROR) {
			if (sqlite3_changes(database) > 0) {
				result = YES;
			}
		}
	}
	sqlite3_finalize( statement );
	return result;
}

@end

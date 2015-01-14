//
//  ITSIconImageDownloadQueue.m
//  StoreSales
//
//  Created by sonson on 09/05/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ITSIconImageDownloadQueue.h"

// Download manager
#import "SQLiteDBController.h"
#import "SNDownloadManager.h"
#import <sqlite3.h>

@implementation ITSIconImageDownloadQueue

@synthesize appleID;

- (BOOL)updateApplicationWithAppleID:(NSString*)appleIdentifier name:(NSString*)name vendorIdentifier:(NSString*)vendorIdentifier icon:(NSData*)icon {
	char *sql = "update application set name = ?, icon = ? where appleIdentifier = ?";
	sqlite3_stmt *statement;
	sqlite3 *database = [SQLiteDBController sharedInstance].database;
	BOOL updateResult = NO;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}	
	else {
		sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_blob(statement, 2, [icon bytes], [icon length], SQLITE_TRANSIENT);
		sqlite3_bind_int(statement, 3, [appleIdentifier intValue]);
		if (sqlite3_step(statement) != SQLITE_ERROR) {
			if (sqlite3_changes(database) > 0) {
				updateResult = YES;
			}
		}
	}
	sqlite3_finalize( statement );
	return updateResult;
}

- (BOOL)insertApplicationWithAppleID:(NSString*)appleIdentifier name:(NSString*)name vendorIdentifier:(NSString*)vendorIdentifier icon:(NSData*)icon {
	char *sql = "insert into application (appleIdentifier, vendorIdentifier, name, icon) values(?, ?, ?, ?)";
	sqlite3_stmt *statement;
	BOOL insertResult = NO;
	sqlite3 *database = [SQLiteDBController sharedInstance].database;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}	
	else {
		sqlite3_bind_int(statement, 1, [appleIdentifier intValue]);
		sqlite3_bind_text(statement, 2, [vendorIdentifier UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 3, [name UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_blob(statement, 4, [icon bytes], [icon length], SQLITE_TRANSIENT);
		if (sqlite3_step(statement) != SQLITE_ERROR) {
			if (sqlite3_changes(database) > 0) {
				insertResult = YES;
			}
		}
	}
	sqlite3_finalize( statement );
	return insertResult;
}

- (NSDictionary*)newApplicationNameAndVendorIdentifierWithAppleID:(NSString*)appleIdentifier {
	char *sql = "select titleEpisodeSeason, vendorIdentifier from (select titleEpisodeSeason, endDate, vendorIdentifier from daily where appleIdentifier = ? union select titleEpisodeSeason, endDate, vendorIdentifier from weekly where appleIdentifier = ?) order by endDate desc limit 0,1;";
	sqlite3_stmt *statement;
	sqlite3 *database = [SQLiteDBController sharedInstance].database;
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		DNSLog( @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg( database ));
	}	
	else {
		sqlite3_bind_text(statement, 1, [appleIdentifier UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 2, [appleIdentifier UTF8String], -1, SQLITE_TRANSIENT);
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

@end

#if TARGET_OS_IPHONE | TARGET_IPHONE_SIMULATOR

// Tool
#import "UIImage+OptimizedPNG.h"
#import "SQLiteDBController.h"
#import "SyncProgressSheet.h"

#pragma mark -
#pragma mark for OSX, iPhone

@implementation ITSIconImageDownloadQueue(OSX_CLIENT)

#pragma mark -
#pragma mark SNDownloadQueueDelegate

- (void)doTaskAfterDownloadingData:(NSData*)data {
	DNSLogMethod
	[[NSNotificationCenter defaultCenter] postNotificationName:@"kSNActionProgressIncrementStep" object:nil];
	if (data != nil) {
		DNSLog(@"Application icon image - %d bytes", [data length]);
		NSString* appleIdentifier = [NSString stringWithFormat:@"%d", self.appleID];
		NSDictionary *dict = [self newApplicationNameAndVendorIdentifierWithAppleID:appleIdentifier];
		if (dict != nil) {
			DNSLog(@"%@,%@", [dict objectForKey:@"name"], [dict objectForKey:@"vendorIdentifier"]);
			NSString *name = [dict objectForKey:@"name"];
			NSString *vendorIdentifier = [dict objectForKey:@"vendorIdentifier"];
			NSData *dataPNG = [data optimizedData];
			if (![self updateApplicationWithAppleID:appleIdentifier name:name vendorIdentifier:vendorIdentifier icon:dataPNG]) {
				[self insertApplicationWithAppleID:appleIdentifier name:name vendorIdentifier:vendorIdentifier icon:dataPNG];
			}
		}
	}
	
	SNDownloadManager *manager = [SNDownloadManager sharedInstance];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  NSLocalizedString(@"Update application info and currency rate...", nil),	kKeyUpdateMessageSyncProgressSheet,
							  [NSNumber numberWithInt:[manager.queueStack count]],							kKeyUpdateProgressSyncProgressSheet,
							  nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:kUpdateSyncProgressSheet object:nil userInfo:userInfo];
}

- (void)doTaskAfterFailedDownload:(NSError*)error {
	DNSLogMethod
#if TARGET_OS_IPHONE | TARGET_IPHONE_SIMULATOR
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
													message:NSLocalizedString(@"Please retry to reload info later.", nil)
												   delegate:nil
										  cancelButtonTitle:nil
										  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
	[alert show];
	[alert release];
#endif
}

@end

#else

#pragma mark -
#pragma mark for MacOSX

@implementation ITSIconImageDownloadQueue(MacOSX_CLIENT)

#pragma mark -
#pragma mark SNDownloadQueueDelegate

- (void)doTaskAfterDownloadingData:(NSData*)data {
	DNSLogMethod
	[[NSNotificationCenter defaultCenter] postNotificationName:@"kSNActionProgressIncrementStep" object:nil];
	if (data != nil) {
		DNSLog(@"Application icon image - %d bytes", [data length]);
		NSString* appleIdentifier = [NSString stringWithFormat:@"%d", self.appleID];
		NSDictionary *dict = [self newApplicationNameAndVendorIdentifierWithAppleID:appleIdentifier];
		if (dict != nil) {
			DNSLog(@"%@,%@", [dict objectForKey:@"name"], [dict objectForKey:@"vendorIdentifier"]);
			NSString *name = [dict objectForKey:@"name"];
			NSString *vendorIdentifier = [dict objectForKey:@"vendorIdentifier"];
			NSData *dataPNG = data;
			if (![self updateApplicationWithAppleID:appleIdentifier name:name vendorIdentifier:vendorIdentifier icon:dataPNG]) {
				[self insertApplicationWithAppleID:appleIdentifier name:name vendorIdentifier:vendorIdentifier icon:dataPNG];
			}
		}
	}
}

@end

#endif
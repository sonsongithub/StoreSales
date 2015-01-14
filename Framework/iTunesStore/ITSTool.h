//
//  ITSTool.h
//  StoreSales
//
//  Created by sonson on 09/05/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface ITSTool : NSObject {
}
+ (NSArray*)appleIdentifiersFromTargetDatabase:(sqlite3*)database;
+ (NSArray*)addOnnIdentifiersFromTargetDatabase:(sqlite3*)database;
+ (NSDictionary*)newApplicationNameAndVendorIdentifierWithAppleID:(NSString*)appleIdentifier targetDatabase:(sqlite3*)database;
+ (BOOL)updateApplicationWithAppleID:(NSString*)appleIdentifier name:(NSString*)name vendorIdentifier:(NSString*)vendorIdentifier icon:(NSData*)icon targetDatabase:(sqlite3*)database;
+ (BOOL)insertApplicationWithAppleID:(NSString*)appleIdentifier name:(NSString*)name vendorIdentifier:(NSString*)vendorIdentifier icon:(NSData*)icon targetDatabase:(sqlite3*)database;
@end

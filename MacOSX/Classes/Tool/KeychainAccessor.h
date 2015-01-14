//
//  KeychainAccessor.h
//  StoreSales
//
//  Created by sonson on 09/06/03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KeychainAccessor : NSObject {
}
+ (NSString *)passwordForService:(NSString *)service account:(NSString *)account;
+ (BOOL)changePasswordForService:(NSString *)service account:(NSString *)account password:(NSString *)password;
@end

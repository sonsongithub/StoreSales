//
//  KeychainAccessor.m
//  StoreSales
//
//  Created by sonson on 09/06/03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KeychainAccessor.h"


@implementation KeychainAccessor

+ (NSString *)passwordForService:(NSString *)service account:(NSString *)account {
	if ([service length] && [account length]) {
		UInt32 passwordLength;
		void* password = nil;
		OSStatus sts = SecKeychainFindGenericPassword(
													  NULL, // default keychain
													  [service lengthOfBytesUsingEncoding:NSUTF8StringEncoding], // length of service name
													  [service UTF8String], // service name
													  [account lengthOfBytesUsingEncoding:NSUTF8StringEncoding], // length of account name
													  [account UTF8String], // account name
													  &passwordLength, // length of password
													  &password, // pointer to password data
													  NULL
													  );
		if (sts==noErr) {
			NSString *result = [[[NSString alloc] initWithBytes:password length:passwordLength encoding:NSUTF8StringEncoding] autorelease];
			SecKeychainItemFreeContent(
									   NULL,
									   password
									   );
			return result;
		}
	}
	return nil;
}

+ (BOOL)changePasswordForService:(NSString *)service account:(NSString *)account password:(NSString *)password {
	SecKeychainItemRef itemRef = nil;
	OSStatus sts = SecKeychainFindGenericPassword(
												  NULL, // default keychain
												  [service lengthOfBytesUsingEncoding:NSUTF8StringEncoding], // length of service name
												  [service UTF8String], // service name
												  [account lengthOfBytesUsingEncoding:NSUTF8StringEncoding], // length of account name
												  [account UTF8String], // account name
												  NULL, // length of password
												  NULL, // pointer to password data
												  &itemRef
												  );
	if (sts==noErr) {
		sts = SecKeychainItemModifyAttributesAndData(
													 itemRef,         // the item reference
													 NULL,            // no change to attributes
													 [password lengthOfBytesUsingEncoding:NSUTF8StringEncoding], // length of password
													 [password UTF8String] // pointer to password data
													 );
	}else{
		sts = SecKeychainAddGenericPassword(
											NULL, // default keychain
											[service lengthOfBytesUsingEncoding:NSUTF8StringEncoding], // length of service name
											[service UTF8String], // service name
											[account lengthOfBytesUsingEncoding:NSUTF8StringEncoding], // length of account name
											[account UTF8String], // account name
											[password lengthOfBytesUsingEncoding:NSUTF8StringEncoding], // length of password
											[password UTF8String], // pointer to password data
											NULL
											);
	}
	return (sts==noErr);
}

@end

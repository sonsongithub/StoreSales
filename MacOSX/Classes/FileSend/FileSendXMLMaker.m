//
//  FileSendXMLMaker.m
//  StoreSales
//
//  Created by sonson on 09/06/03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FileSendXMLMaker.h"

// Tool
#import "GTMBase64.h"

@implementation FileSendXMLMaker

+ (NSData*)XMLToSendData:(NSData*)data filepath:(NSString*)path remained:(int)remained already:(int)already {
	DNSLogMethod
	NSString *filename = [path lastPathComponent];
	NSString *string = [GTMBase64 stringByEncodingData:data];
	NSMutableString *xml = [NSMutableString string];
	[xml appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
	[xml appendString:@"<StoreSales>"];
	[xml appendFormat:@"<status>send</status>"];
	[xml appendFormat:@"<already>%d</already>", already];
	[xml appendFormat:@"<remained>%d</remained>", remained];
	[xml appendFormat:@"<data>%@</data>", string];
	[xml appendFormat:@"<filename>%@</filename>", filename];
	[xml appendFormat:@"<databytes>%d</databytes>", [data length]];
	[xml appendString:@"</StoreSales>"];
	return [xml dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData*)XMLToSendRequestOK {
	DNSLogMethod
	NSMutableString *xml = [NSMutableString string];
	[xml appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
	[xml appendString:@"<StoreSales>"];
	[xml appendFormat:@"<status>requestOK</status>"];
	[xml appendString:@"</StoreSales>"];
	return [xml dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData*)XMLToSendAuthorizationFailed {
	DNSLogMethod
	NSMutableString *xml = [NSMutableString string];
	[xml appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
	[xml appendString:@"<StoreSales>"];
	[xml appendFormat:@"<status>AuthorizationFailed</status>"];
	[xml appendString:@"</StoreSales>"];
	return [xml dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData*)XMLToSendTaskFinished {
	DNSLogMethod
	NSMutableString *xml = [NSMutableString string];
	[xml appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
	[xml appendString:@"<StoreSales>"];
	[xml appendFormat:@"<status>TaskFinished</status>"];
	[xml appendString:@"</StoreSales>"];
	return [xml dataUsingEncoding:NSUTF8StringEncoding];
}

@end

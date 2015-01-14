//
//  NSString+substringFromSuffixToPrefix.m
//  StoreSales
//
//  Created by sonson on 10/09/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+substringFromSuffixToPrefix.h"

@implementation NSString(substringFromSuffixToPrefix)

- (NSString*)substringFromSuffix:(NSString*)suffix ToPrefix:(NSString*)prefix {
	
	
	NSScanner *scanner = [[NSScanner alloc] initWithString:self];
	
	NSString *value = nil;
	
	if ([scanner scanUpToString:suffix intoString:nil]) {
	}
	if ([scanner scanString:suffix intoString:nil]) {
	}
	if ([scanner scanUpToString:prefix intoString:&value]) {
	}
	
	[scanner release];
	
	return value;
}

@end

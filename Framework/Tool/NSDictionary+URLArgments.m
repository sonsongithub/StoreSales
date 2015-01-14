//
//  NSDictionary+URLArgments.m
//  StoreSales
//
//  Created by sonson on 09/02/24.
//  Copyright 2009 sonson. All rights reserved.
//

#import "NSDictionary+URLArgments.h"
#import "NSString+URIEscape.h"

@implementation NSDictionary(URLArgments)

- (NSMutableString*)URLArgments {
	NSMutableString *argments = [NSMutableString string];
	[argments appendString:@"?"];
	for (NSString* key in [self allKeys]) {
		NSString *escapedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		//NSString *escapedValue = [[self objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSString *escapedValue = [[self objectForKey:key] stringByAddingPercentEscapesAllSingleByteCharsUsingEncoding:NSUTF8StringEncoding];
		NSString* string = [NSString stringWithFormat:@"%@=%@&", escapedKey, escapedValue];
		[argments appendString:string];
	}
	if ([argments length] > 1) {
		[argments deleteCharactersInRange:NSMakeRange([argments length]-1, 1)];
	}
	return argments;
}

@end

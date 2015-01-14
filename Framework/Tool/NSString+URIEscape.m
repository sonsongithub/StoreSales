//
//  NSString+URIEscape.m
//  StoreSales
//
//  Created by sonson on 09/04/05.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSString+URIEscape.h"

@implementation NSString(URIEscape)

- (NSString*)stringByAddingPercentEscapesAllSingleByteCharsUsingEncoding:(NSStringEncoding)encodeing {
	CFStringEncoding cfStrEnc = CFStringConvertNSStringEncodingToEncoding(encodeing);
	NSString* escapedFirstStep = (NSString*)CFURLCreateStringByAddingPercentEscapes(
																	 NULL,
																	 (CFStringRef)self,
																	 nil,
																	 nil,
																	 cfStrEnc);
	NSString* escapedSecondStep = (NSString*)CFURLCreateStringByAddingPercentEscapes(
																		   NULL,
																		   (CFStringRef)escapedFirstStep,
																		   nil,
																		   (CFStringRef)@";:@&=/+",
																		   cfStrEnc);
	NSString *result = [NSString stringWithFormat:@"%@", escapedSecondStep];
	[escapedFirstStep release];
	[escapedSecondStep release];
	return result;
}

@end

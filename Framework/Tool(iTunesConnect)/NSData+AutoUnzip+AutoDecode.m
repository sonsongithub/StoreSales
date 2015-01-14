//
//  NSData+AutoUnzip+AutoDecode.m
//  StoreSales
//
//  Created by sonson on 09/06/03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSData+AutoUnzip+AutoDecode.h"

// Tool
#import "GTMNSData+zlib.h"
#import "UICNSString+AutoDecoder.h"

@implementation NSData(AutoUnzipAutoDecode)

- (NSString*)stringAutoUnzipAndDecoding {
	NSData *expandedData = [NSData gtm_dataByInflatingData:self];
	
	if (expandedData == nil) {
		return [NSString stringAutoDecodeFromData:self];
	}
	else {
		return [NSString stringAutoDecodeFromData:expandedData];
	}
}

@end

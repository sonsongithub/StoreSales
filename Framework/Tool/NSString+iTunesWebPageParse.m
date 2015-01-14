//
//  NSString+iTunesWebPageParse.m
//  StoreSales
//
//  Created by sonson on 11/05/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+iTunesWebPageParse.h"


@implementation NSString(iTunesWebPageParse)

- (NSString*)extractiTunesWebPageImageURL {
	NSString *leftStackElement = [self extractLeftStack];
	NSString *divElement = [leftStackElement extractArtworkDIV];
	
	NSString *output = nil;
	
	NSScanner *scanner = [NSScanner scannerWithString:divElement];
	if ([scanner scanUpToString:@"<img " intoString:nil]) {
	}
	if ([scanner scanString:@"<img " intoString:nil]) {
	}
	if ([scanner scanUpToString:@"src=\"" intoString:nil]) {
	}
	if ([scanner scanString:@"src=\"" intoString:nil]) {
	}
	if ([scanner scanUpToString:@"\"" intoString:&output]) {
	}
	
	return output;
}

- (NSString*)extractLeftStack {
	NSScanner *scanner = [NSScanner scannerWithString:self];
	NSString *output = nil;
	if ([scanner scanUpToString:@"<div id=\"left-stack\">" intoString:nil]) {
	}
	if ([scanner scanString:@"</div>" intoString:nil]) {
	}
	if ([scanner scanUpToString:@"</div>" intoString:&output]) {
	}
	return output;
}

- (NSString*)extractArtworkDIV {
	NSScanner *scanner = [NSScanner scannerWithString:self];
	NSString *output = nil;
	if ([scanner scanUpToString:@"<div class=\"artwork\">" intoString:nil]) {
	}
	if ([scanner scanString:@"</div>" intoString:nil]) {
	}
	if ([scanner scanUpToString:@"</div>" intoString:&output]) {
	}
	return output;
}

@end

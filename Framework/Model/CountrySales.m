//
//  CountrySales.m
//  StoreSales
//
//  Created by sonson on 09/03/03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CountrySales.h"
#import "CountryInfo.h"

// read/write with binary file format
#import "binaryIO.h"

@implementation CountrySales

@synthesize info;
@synthesize value;
@synthesize valueString;
@synthesize ratio;
@synthesize countryCode;

#pragma mark -
#pragma mark Serialize with binary

+ (CountrySales*)CountrySalesFromFile:(FILE*)fp {
	// data identifier
	CountrySales* obj = [[[CountrySales alloc] init] autorelease];
	[obj read:fp];
	return obj;
}

- (void)write:(FILE*)fp {
	writeNSString(fp, valueString);
	writeNSString(fp, self.info.countryCode);
	writeDouble(fp, &value);
	writeDouble(fp, &ratio);
}

- (void)read:(FILE*)fp {
	loadNSString(fp, &valueString);
	loadNSString(fp, &countryCode);
	loadDouble(fp, &value);
	loadDouble(fp, &ratio);
}

#pragma mark -
#pragma mark Override

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	valueString = [[coder decodeObjectForKey:@"valueString"] retain];
	countryCode = [[coder decodeObjectForKey:@"countryCode"] retain];
	value = [coder decodeDoubleForKey:@"value"];
	ratio = [coder decodeDoubleForKey:@"ratio"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:valueString forKey:@"valueString"];
	[encoder encodeObject:self.info.countryCode forKey:@"countryCode"];
	[encoder encodeDouble:value forKey:@"value"];
	[encoder encodeDouble:ratio forKey:@"ratio"];
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[countryCode release];
	[valueString release];
	[info release];
	[super dealloc];
}

@end

//
//  Sales.m
//  StoreSales
//
//  Created by sonson on 09/02/26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ApplicationSales.h"
#import "ApplicationInfo.h"
#import "binaryIO.h"

@implementation ApplicationSales

@synthesize info;
@synthesize value;
@synthesize ratio;
@synthesize valueString;
@synthesize applicationIdentifierString;

#pragma mark -
#pragma mark Serialize with binary

+ (ApplicationSales*)ApplicationSalesFromFile:(FILE*)fp {
	// data identifier
	ApplicationSales* obj = [[[ApplicationSales alloc] init] autorelease];
	if ([obj read:fp])
		return obj;
	DNSLog(@"Read failed");
	return nil;
}

- (void)write:(FILE*)fp {
	writeNSString(fp, valueString);
	writeNSString(fp, [NSString stringWithFormat:@"%d", self.info.appleIdentifier]);
	writeDouble(fp, &value);
	writeDouble(fp, &ratio);
}

- (BOOL)read:(FILE*)fp {
	int r = 1;
	r = r & loadNSString(fp, &valueString);
	r = r & loadNSString(fp, &applicationIdentifierString);
	r = r & loadDouble(fp, &value);
	r = r & loadDouble(fp, &ratio);
	return (r != 0);
}

#pragma mark -
#pragma mark Override

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	valueString = [[coder decodeObjectForKey:@"valueString"] retain];
	applicationIdentifierString = [[coder decodeObjectForKey:@"applicationIdentifierString"] retain];
	value = [coder decodeDoubleForKey:@"value"];
	ratio = [coder decodeDoubleForKey:@"ratio"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:valueString forKey:@"valueString"];
	[encoder encodeObject:[NSString stringWithFormat:@"%d", self.info.appleIdentifier] forKey:@"applicationIdentifierString"];
	[encoder encodeDouble:value forKey:@"value"];
	[encoder encodeDouble:ratio forKey:@"ratio"];
}

- (NSString*)description {
	return [NSString stringWithFormat:@"%@:%@:%.2f", info, applicationIdentifierString, value];
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[info release];
	[valueString release];
	[applicationIdentifierString release];
	[super dealloc];
}

@end

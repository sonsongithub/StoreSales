//
//  DailySales.m
//  StoreSales
//
//  Created by sonson on 09/03/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PeriodicalSales.h"

// read/write with binary file format
#import "binaryIO.h"

NSDateFormatter *DateFormatter_dd = nil;
NSDateFormatter *DateFormatter_DD = nil;
NSDateFormatter *DateFormatter_MM = nil;
NSDateFormatter *DateFormatter_Period = nil;

@implementation PeriodicalSales

@synthesize dateIdentifier;
@synthesize beginDate;
@synthesize endDate;
@synthesize dateString;
@synthesize dateWeekString;
@synthesize monthString;
@synthesize beginDateString;
@synthesize endDateString;
@synthesize	periodicalString;
@synthesize value;
@synthesize valueString;
@synthesize ratio;

#pragma mark -
#pragma mark Class method

+ (void)initialize {
	if (DateFormatter_dd == nil) {
		DateFormatter_dd = [[NSDateFormatter alloc] init];
		[DateFormatter_dd setDateFormat:@"d"];
	}
	if (DateFormatter_DD == nil) {
		DateFormatter_DD = [[NSDateFormatter alloc] init];
		//[DateFormatter_DD setDateFormat:@"ccc"];
		[DateFormatter_DD setDateFormat:@"EEEE"];
	}
	if (DateFormatter_MM == nil) {
		DateFormatter_MM = [[NSDateFormatter alloc] init];
		//[DateFormatter_MM setDateFormat:@"LLL"];
		[DateFormatter_MM setDateFormat:@"LLLL"];
	}
	if (DateFormatter_Period == nil) {
		DateFormatter_Period = [[NSDateFormatter alloc] init];
		[DateFormatter_Period setDateStyle:NSDateFormatterShortStyle];
	}
}

#pragma mark -
#pragma mark Setter method

// setter
- (void)setBeginDate:(NSDate*)newValue {
	if (newValue != beginDate && newValue != nil) {
		[beginDate release];
		beginDate = [newValue retain];
		
		self.dateString = [DateFormatter_dd stringFromDate:beginDate];
		self.dateWeekString = [DateFormatter_DD stringFromDate:beginDate];
		self.monthString = [DateFormatter_MM stringFromDate:beginDate];
		self.beginDateString = [DateFormatter_Period stringFromDate:beginDate];
	}
}

- (void)setEndDate:(NSDate*)newValue {
	if (newValue != endDate && newValue != nil) {
		[endDate release];
		endDate = [newValue retain];
		self.periodicalString = [NSString stringWithFormat:@"%@ - %@", self.beginDateString, [DateFormatter_Period stringFromDate:endDate]];
	}
}

#pragma mark -
#pragma mark Serialize with binary

+ (PeriodicalSales*)PeriodicalSalesFromFile:(FILE*)fp {
	// data identifier
	PeriodicalSales* obj = [[[PeriodicalSales alloc] init] autorelease];
	if ([obj read:fp])
		return obj;
	DNSLog(@"Read failed");
	return nil;
}

- (int)write:(FILE*)fp {
	int r = 1;
	// essential
	r = r & writeDouble(fp, &ratio);
	r = r & writeDouble(fp, &value);
	r = r & writeNSString(fp, valueString);
	r = r & writeNSDate(fp, beginDate);
	r = r & writeNSDate(fp, endDate);
	r = r & writeNSString(fp, dateString);
	r = r & writeNSString(fp, dateWeekString);
	r = r & writeNSString(fp, monthString);
	r = r & writeNSString(fp, beginDateString);
	r = r & writeNSString(fp, periodicalString);
	
	// non essential
	writeNSString(fp, dateIdentifier);
	writeNSString(fp, endDateString);
	return r;
}

- (int)read:(FILE*)fp {
	int r = 1;
	// essential
	r = r & loadDouble(fp, &ratio);
	r = r & loadDouble(fp, &value);
	r = r & loadNSString(fp, &valueString);
	r = r & loadNSDate(fp, &beginDate);
	r = r & loadNSDate(fp, &endDate);
	r = r & loadNSString(fp, &dateString);
	r = r & loadNSString(fp, &dateWeekString);
	r = r & loadNSString(fp, &monthString);
	r = r & loadNSString(fp, &beginDateString);
	r = r & loadNSString(fp, &periodicalString);
	
	// nont essential
	loadNSString(fp, &dateIdentifier);
	loadNSString(fp, &endDateString);
	return r;
}

#pragma mark -
#pragma mark Serialize

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	
	// data identifier
	dateIdentifier = [[coder decodeObjectForKey:@"dateIdentifier"] retain];
	
	// raw data for drawing
	ratio = [coder decodeDoubleForKey:@"ratio"];
	value = [coder decodeDoubleForKey:@"value"];
	valueString = [[coder decodeObjectForKey:@"valueString"] retain];
	
	// date info
	beginDate = [[coder decodeObjectForKey:@"beginDate"] retain];
	endDate = [[coder decodeObjectForKey:@"endDate"] retain];
	
	// date string for drawing on a cell
	dateString = [[coder decodeObjectForKey:@"dateString"] retain];
	dateWeekString = [[coder decodeObjectForKey:@"dateWeekString"] retain];
	monthString = [[coder decodeObjectForKey:@"monthString"] retain];
	beginDateString = [[coder decodeObjectForKey:@"beginDateString"] retain];
	endDateString = [[coder decodeObjectForKey:@"endDateString"] retain];
	periodicalString = [[coder decodeObjectForKey:@"periodicalString"] retain];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	// data identifier
	[encoder encodeObject:dateIdentifier forKey:@"dateIdentifier"];
	
	// raw data for drawing
	[encoder encodeDouble:ratio forKey:@"ratio"];
	[encoder encodeDouble:value forKey:@"value"];
	[encoder encodeObject:valueString forKey:@"valueString"];
	
	// date info
	[encoder encodeObject:beginDate forKey:@"beginDate"];
	[encoder encodeObject:endDate forKey:@"endDate"];
	
	// date string for drawing on a cell
	[encoder encodeObject:dateString forKey:@"dateString"];
	[encoder encodeObject:dateWeekString forKey:@"dateWeekString"];
	[encoder encodeObject:monthString forKey:@"monthString"];
	[encoder encodeObject:beginDateString forKey:@"beginDateString"];
	[encoder encodeObject:endDateString forKey:@"endDateString"];
	[encoder encodeObject:periodicalString forKey:@"periodicalString"];
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[dateIdentifier release];
	[beginDate release];
	[endDate release];
	[dateString release];
	[dateWeekString release];
	[monthString release];
	[beginDateString release];
	[endDateString release];
	[valueString release];
	[periodicalString release];
	[super dealloc];
}

@end

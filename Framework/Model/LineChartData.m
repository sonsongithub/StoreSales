//
//  LineChartData.m
//  StoreSales
//
//  Created by sonson on 09/03/27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LineChartData.h"

NSDateFormatter *FormatDate = nil;

@implementation LineChartData

@synthesize date;
@synthesize dateString;
@synthesize ratio;
@synthesize value;
@synthesize timeInterval;

+ (void)initialize {
	if (FormatDate == nil) {
		FormatDate = [[NSDateFormatter alloc] init];
		[FormatDate setDateFormat:@"MM/dd"];
	}
}

- (NSString*)dateString {
	if (dateString == nil) {
		dateString = [[FormatDate stringFromDate:self.date] retain];
	}
	return dateString;
}

- (NSDate*)date {
	if (date == nil) {
		date = [[NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval] retain];
	}
	return date;
}

- (void)dealloc {
	[date release];
	[dateString release];
	[super dealloc];
}

@end

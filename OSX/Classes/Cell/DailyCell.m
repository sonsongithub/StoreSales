//
//  DailyCell.m
//  StoreSales
//
//  Created by sonson on 09/03/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DailyCell.h"
#import "SNCellForDrawRect.h"

@implementation DailyCell

- (void)drawItemRect:(CGRect)rect {
	[self drawCalendarRect:rect upperString:self.sales.dateWeekString lowerString:self.sales.dateString];
	[self drawAsTitle:sales.beginDateString rect:rect];
	[self drawGraphRatio:sales.ratio rect:rect orderType:orderType];
	[self drawAsValue:sales.valueString rect:(CGRect)rect];
}

#pragma mark -
#pragma mark Override

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[self drawItemRect:rect];
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[super dealloc];
}

@end

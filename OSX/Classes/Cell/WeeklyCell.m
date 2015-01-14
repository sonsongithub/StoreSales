//
//  WeeklyCell.m
//  StoreSales
//
//  Created by sonson on 09/03/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WeeklyCell.h"
#import "SNCellForDrawRect.h"

UIFont *WeeklyCellDateFont = nil;
UIColor *WeeklyCellDateColor = nil;
UIColor *WeeklyCellDateShadowColor = nil;
UIColor *WeeklyCellDateSelectedColor = nil;

UIFont *WeeklyCellValueFont = nil;
UIColor *WeeklyCellValueColor = nil;

CGGradientRef WeekyCellGraphGradient = NULL;

@implementation WeeklyCell

- (void)drawItemRect:(CGRect)rect {
	[self drawCalendarRect:rect upperString:self.sales.monthString lowerString:self.sales.dateString];
	[self drawAsTitle:sales.periodicalString rect:rect];
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

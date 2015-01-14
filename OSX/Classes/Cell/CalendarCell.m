//
//  CalendarCell.m
//  StoreSales
//
//  Created by sonson on 09/03/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CalendarCell.h"
#import "UIImage+ClippedIcon.h"

UIImage *DailyCellCalendarImage = nil;
UIFont *DailyCellCalendarSmallFont = nil;
UIFont *DailyCellCalendarBigFont = nil;
UIColor	*DailyCellCalendarSmallFontShadowColor = nil;

#define CALENDARCELL_CAL_AREA_WIDTH		80
#define CALENDARCELL_CAL_AREA_HEIGHT	DEFAULT // cell height

#define CALENDARCELL_CAL_WIDTH			57
#define CALENDARCELL_CAL_HEIGHT			57

#define CALENDARCELL_CAL_MONTH_TOP			10
#define CALENDARCELL_CAL_MONTH_LEFT_SPACE	(0)
#define CALENDARCELL_CAL_DATE_TOP			21
#define CALENDARCELL_CAL_DATE_LEFT_SPACE	(0)

@implementation CalendarCell

@synthesize sales;
@dynamic odd;
@synthesize orderType;

+ (void)initialize {
	if (DailyCellCalendarImage == nil) {
		DailyCellCalendarImage = [[UIImage imageNamed:@"calendar.png"] retain];
	}
	if (DailyCellCalendarBigFont == nil) {
		DailyCellCalendarBigFont = [[UIFont boldSystemFontOfSize:35] retain];
	}
	if (DailyCellCalendarSmallFont == nil) {
		DailyCellCalendarSmallFont = [[UIFont boldSystemFontOfSize:8] retain];
	}
	if (DailyCellCalendarSmallFontShadowColor == nil) {
		DailyCellCalendarSmallFontShadowColor = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5] retain];
	}
}

- (void)drawCalendarRect:(CGRect)rect upperString:(NSString*)upperString lowerString:(NSString*)lowerString {
	// draw calendar icon and date description
	CGSize size;
	CGRect frame;
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGRect calendarRect = CGRectMake( 0, 0, CALENDARCELL_CAL_WIDTH, CALENDARCELL_CAL_HEIGHT);
	calendarRect.origin.x = (int)(CALENDARCELL_CAL_AREA_WIDTH - CALENDARCELL_CAL_WIDTH) / 2;
	calendarRect.origin.y = (int)(rect.size.height - CALENDARCELL_CAL_HEIGHT) / 2;
	[DailyCellCalendarImage drawInRect:calendarRect];
	
	CGContextSaveGState(context);
	CGContextAlternativeSetShadowWithColor(context, CGSizeMake(0, 0.5), 0.1, DailyCellCalendarSmallFontShadowColor.CGColor);
	CGContextSetRGBFillColor( context, 255/255.0f, 255/255.0f, 255/255.0f, 1.f);
	size = [upperString sizeWithFont:DailyCellCalendarSmallFont];
	frame.origin.x = CGRectGetMidX(calendarRect) - size.width / 2 + CALENDARCELL_CAL_MONTH_LEFT_SPACE;
	frame.origin.y = CALENDARCELL_CAL_MONTH_TOP-1;
	frame.size = size;
	[upperString drawInRect:frame withFont:DailyCellCalendarSmallFont];
	CGContextRestoreGState(context);
	
	CGContextSetRGBFillColor( context, 51/255.0f, 51/255.0f, 51/255.0f, 1.f);
	size = [lowerString sizeWithFont:DailyCellCalendarBigFont];
	frame.origin.x = CGRectGetMidX(calendarRect) - size.width / 2 + CALENDARCELL_CAL_DATE_LEFT_SPACE;
	frame.origin.y = CALENDARCELL_CAL_DATE_TOP;
	frame.size = size;
	[lowerString drawInRect:frame withFont:DailyCellCalendarBigFont];
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[sales release];
	[super dealloc];
}

@end

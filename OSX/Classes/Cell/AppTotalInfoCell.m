//
//  AppTotalInfoCell.m
//  StoreSales
//
//  Created by sonson on 09/02/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppTotalInfoCell.h"
#import "ApplicationSales.h"
#import "ApplicationInfo.h"
#import "UIImage+ClippedIcon.h"

UIFont *AppTotalInfoCellTotalFont = nil;
UIColor *AppTotalInfoCellTotalColor = nil;
UIColor *AppTotalInfoCellTotalShadowColor = nil;

UIFont *AppTotalInfoCellValueFont = nil;
UIColor *AppTotalInfoCellValueColor = nil;
UIColor *AppTotalInfoCellValueShadowColor = nil;

@implementation AppTotalInfoCell

@synthesize appInfoArray;
@synthesize orderType;

+ (void)initialize {
	// setup value string beside graph.
	if (AppTotalInfoCellTotalFont == nil) {
		AppTotalInfoCellTotalFont =  [[UIFont boldSystemFontOfSize:20] retain];            
	}
	if (AppTotalInfoCellTotalColor == nil) {
		AppTotalInfoCellTotalColor = [[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f] retain];
	}
	if (AppTotalInfoCellTotalShadowColor == nil) {
		AppTotalInfoCellTotalShadowColor = [[UIColor colorWithRed:194/255.0f green:194/255.0f blue:194/255.0f alpha:1.0f] retain];
	}
	
	// setup value string at right field.
	if (AppTotalInfoCellValueFont == nil) {
		AppTotalInfoCellValueFont =  [[UIFont boldSystemFontOfSize:20] retain];
	}
	if (AppTotalInfoCellValueColor == nil) {
		AppTotalInfoCellValueColor = [[UIColor colorWithRed:71/255.0f green:71/255.0f blue:71/255.0f alpha:1.0f] retain];
	}
	if (AppTotalInfoCellValueShadowColor == nil) {
		AppTotalInfoCellValueShadowColor = [[UIColor colorWithRed:194/255.0f green:194/255.0f blue:194/255.0f alpha:1.0f] retain];
	}
}

+ (float)height {
	return (TOP_MARGIN_CIRCLE_GRAPH + RADIUS_CIRCLE_GRAPH) * 2;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
	}
	return self;
}

- (void)drawStringRect:(CGRect)rect {
	float totalValue = 0;
	NSString *string = nil;
	for (ApplicationSales *sales in appInfoArray) {
		totalValue += sales.value;
	}
	if (orderType == CellOrderUnits) {
		//value.text = 
		string = [NSString stringWithFormat:@"%d", (int)totalValue];
	}
	else if (orderType == CellOrderSales) {
		//value.text = 
		string = [NSString stringWithFormat:@"%@%d", UIAppDelegate.currencyDescription, (int)totalValue];
	}
	else if (orderType == CellOrderUpgrade) {
		//value.text = 
		string = [NSString stringWithFormat:@"%d", (int)totalValue];
	}
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGContextAlternativeSetShadowWithColor(context, CGSizeMake(0, -2.2), 0.0, AppTotalInfoCellValueShadowColor.CGColor);
	[AppTotalInfoCellValueColor setFill];
	CGSize size = [string sizeWithFont:AppTotalInfoCellValueFont];
	CGRect valueRect = CGRectMake(rect.size.width - 20 - size.width, (rect.size.height - size.height) / 2, 0, 0);
	valueRect.size = size;
	[string drawInRect:valueRect withFont:AppTotalInfoCellValueFont];
	
	[AppTotalInfoCellTotalColor setFill];
	NSString *titleTemp = NSLocalizedString(@"Total", nil);
	size = [titleTemp sizeWithFont:AppTotalInfoCellTotalFont];
	CGRect titleRect = CGRectMake(100, (rect.size.height - size.height) / 2, 0, 0);
	titleRect.size = size;
	[titleTemp drawInRect:titleRect withFont:AppTotalInfoCellTotalFont];
	CGContextRestoreGState(context);
}

- (void)drawGraphRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGContextAlternativeSetShadowWithColor(context, CGSizeMake(0, 0), 3.0, [UIColor blackColor].CGColor);
	float ratio = 0.0;
	float startDeg = 0;
	float endDeg = 0;
	float hueStep = 0.3;
	
	for (ApplicationSales *sales in [appInfoArray reverseObjectEnumerator]) {
		startDeg = ratio * M_PI * 2.0 - M_PI / 2;
		UIColor *fillColor = nil;
		endDeg = startDeg - sales.ratio * M_PI * 2.0;
		ratio -= sales.ratio;
		fillColor = sales.info.color;
		hueStep += 1.0 / [appInfoArray count];
		[fillColor setFill];
		CGContextMoveToPoint(context, CENTER_X_CIRCLE_GRAPH, CENTER_Y_CIRCLE_GRAPH);
		CGContextAddArc(context, CENTER_X_CIRCLE_GRAPH, CENTER_Y_CIRCLE_GRAPH, RADIUS_CIRCLE_GRAPH, endDeg, startDeg, false);
		CGContextAddLineToPoint(context, CENTER_X_CIRCLE_GRAPH, CENTER_Y_CIRCLE_GRAPH);
		CGContextFillPath(context);
	}
	CGContextRestoreGState(context);
}

- (void)drawIconRect:(CGRect)rect {
	float ratio = 0.0;
	float startDeg = 0;
	float endDeg = 0;
	for (ApplicationSales *sales in [appInfoArray reverseObjectEnumerator]) {
		startDeg = ratio * M_PI * 2.0 - M_PI / 2;
		//UIColor *fillColor = nil;
		endDeg = startDeg - sales.ratio * M_PI * 2.0;
		ratio -= sales.ratio;
		double deg = (startDeg + endDeg) / 2;
		CGRect frame;
		frame.origin.x = RADIUS_CIRCLE_ICON * cos(deg) + CENTER_X_CIRCLE_GRAPH - ICON_WIDTH_CIRCLE_GRAPH/2;
		frame.origin.y = RADIUS_CIRCLE_ICON * sin(deg) + CENTER_Y_CIRCLE_GRAPH - ICON_HEIGHT_CIRCLE_GRAPH/2;
		frame.size.width = ICON_WIDTH_CIRCLE_GRAPH;
		frame.size.height = ICON_HEIGHT_CIRCLE_GRAPH;
		if (sales.ratio > 0) {
			[sales.info.icon drawClippedAndShadowedIconInRect:frame];
		}
	}
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor( context, 173/255.0f, 173/255.0f, 176/255.0f, 1.f);
	CGContextFillRect(context, rect);
	
	[self drawGraphRect:rect];
	[self drawIconRect:rect];
	[self drawStringRect:rect];
}

- (void) layoutSubviews {
	[super layoutSubviews];
	[self setNeedsDisplay];
}

- (void)dealloc {
	[appInfoArray release];
    [super dealloc];
}

@end

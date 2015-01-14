//
//  TwoGraphCell.m
//  StoreSales
//
//  Created by sonson on 09/03/06.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GraphCell.h"

UIFont *TwoGraphCellTitleFont = nil;
UIColor *TwoGraphCellTitleColor = nil;
UIColor *TwoGraphCellTitleShadowColor = nil;

UIFont *TwoGraphCellValueFont = nil;
UIColor *TwoGraphCellValueColor = nil;
UIColor *TwoGraphCellValueShadowColor = nil;

CGGradientRef TwoGraphCellGraphGradient[GRAPH_COLOR_COUNT] = {NULL, NULL, NULL, NULL, NULL, NULL};

#define GRAPHCELL_LEFT_GRAPH_MARGIN		80
#define GRAPHCELL_RIGHT_GRAPH_MARGIN	40
#define GRAPHCELL_TOP_GRAPH_MARGIN		30
#define GRAPHCELL_GRAPH_HEIGHT			30

#define GRAPHCELL_LEFT_TITLE_MARGIN		80
#define GRAPHCELL_TOP_TITLE_MARGIN		8

#define GRAPHCELL_LEFT_VALUE_MARGIN		85
#define GRAPHCELL_TOP_VALUE_MARGIN		37

@implementation GraphCell

@synthesize odd;

+ (void)initialize {
	////////////////////////////////////////////////////////////////////////////////
	// setup font and color instance
	if (TwoGraphCellTitleFont == nil) {
		TwoGraphCellTitleFont = [[UIFont boldSystemFontOfSize:14] retain];
	}
	if (TwoGraphCellTitleColor == nil) {
		TwoGraphCellTitleColor = [[UIColor blackColor] retain];
	}
	if (TwoGraphCellTitleShadowColor == nil) {
		TwoGraphCellTitleShadowColor = [[UIColor colorWithRed:194/255.0f green:194/255.0f blue:194/255.0f alpha:1.0f] retain];
	}
	if (TwoGraphCellValueFont == nil) {
		TwoGraphCellValueFont = [[UIFont boldSystemFontOfSize:14] retain];
	}
	if (TwoGraphCellValueColor == nil) {
		TwoGraphCellValueColor = [[UIColor blackColor] retain];
	}
	if (TwoGraphCellValueShadowColor == nil) {
		TwoGraphCellValueShadowColor = [[UIColor blackColor] retain];
	}
	////////////////////////////////////////////////////////////////////////////////
	// setup gradient color
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	if (TwoGraphCellGraphGradient[GraphColorBlue] == NULL) {
		CGFloat colors[] = {
			35.0f / 255.0, 58.0f / 255.0, 136.0f / 255.0, 1.00,
			48.0f / 255.0, 86.0f / 255.0, 183.0f / 255.0, 1.00
		};
		TwoGraphCellGraphGradient[GraphColorBlue] = CGGradientCreateWithColorComponents( rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4) );
	}
	if (TwoGraphCellGraphGradient[GraphColorGreen] == NULL) {
		CGFloat colors[] = {
			48.0f / 255.0, 98.0f / 255.0, 15.0f / 255.0, 1.00,
			70.0f / 255.0, 142.0f / 255.0, 19.0f / 255.0, 1.00
		};
		TwoGraphCellGraphGradient[GraphColorGreen] = CGGradientCreateWithColorComponents( rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4) );
	}
	if (TwoGraphCellGraphGradient[GraphColorEmerald] == NULL) {
		CGFloat colors[] = {
			50.0f / 255.0, 100.0f / 255.0, 100.0f / 255.0, 1.00,
			77.0f / 255.0, 150.0f / 255.0, 150.0f / 255.0, 1.00
		};
		TwoGraphCellGraphGradient[GraphColorEmerald] = CGGradientCreateWithColorComponents( rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4) );
	}
	if (TwoGraphCellGraphGradient[GraphColorPerple] == NULL) {
		CGFloat colors[] = {
			53.0f / 255.0, 34.0f / 255.0, 108.0f / 255.0, 1.00,
			75.0f / 255.0, 42.0f / 255.0, 172.0f / 255.0, 1.00
		};
		TwoGraphCellGraphGradient[GraphColorPerple] = CGGradientCreateWithColorComponents( rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4) );
	}
	if (TwoGraphCellGraphGradient[GraphColorRed] == NULL) {
		CGFloat colors[] = {
			89.0f / 255.0, 19.0f / 255.0, 21.0f / 255.0, 1.00,
			127.0f / 255.0, 27.0f / 255.0, 19.0f / 255.0, 1.00
		};
		TwoGraphCellGraphGradient[GraphColorRed] = CGGradientCreateWithColorComponents( rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4) );
	}
	if (TwoGraphCellGraphGradient[GraphColorGray] == NULL) {
		CGFloat colors[] = {
			100.0f / 255.0, 100.0f / 255.0, 100.0f / 255.0, 1.00,
			150.0f / 255.0, 150.0f / 255.0, 150.0f / 255.0, 1.00
		};
		TwoGraphCellGraphGradient[GraphColorGray] = CGGradientCreateWithColorComponents( rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4) );
	}
	CGColorSpaceRelease(rgb);
}

#pragma mark -
#pragma mark Drawing background, change color based on array number

// draw back ground color
// 2 patterns, odd or even
- (void)drawUnselectedBackgroundRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	if (odd) {
		CGContextSetRGBFillColor( context, 152/255.0f, 152/255.0f, 156/255.0f, 1.f);
	}
	else {
		CGContextSetRGBFillColor( context, 173/255.0f, 173/255.0f, 176/255.0f, 1.f);
	}
	CGContextFillRect(context, rect);
	
	if (odd) {
		CGContextSetLineWidth(context, 2.0);
		CGContextSetRGBStrokeColor(context, 187/255.0f, 188/255.0f, 191/255.0f, 1.f);
		CGContextMoveToPoint(context, 0, 0);
		CGContextAddLineToPoint(context, rect.size.width, 0);
		CGContextStrokePath(context);
		
		CGContextSetLineWidth(context, 1.0);
		CGContextSetRGBStrokeColor(context, 117/255.0f, 118/255.0f, 121/255.0f, 1.f);
		CGContextMoveToPoint(context, 0, rect.size.height );
		CGContextAddLineToPoint(context, rect.size.width, rect.size.height );
		CGContextStrokePath(context);
	}
	else {
		CGContextSetLineWidth(context, 2.0);
		CGContextSetRGBStrokeColor(context, 207/255.0f, 207/255.0f, 209/255.0f, 1.f);
		CGContextMoveToPoint(context, 0, 0);
		CGContextAddLineToPoint(context, rect.size.width, 0);
		CGContextStrokePath(context);
		
		CGContextSetLineWidth(context, 1.0);
		CGContextSetRGBStrokeColor(context, 118/255.0f, 118/255.0f, 121/255.0f, 1.f);
		CGContextMoveToPoint(context, 0, rect.size.height );
		CGContextAddLineToPoint(context, rect.size.width, rect.size.height );
		CGContextStrokePath(context);
	}
/*
	CGContextSetRGBStrokeColor(context, 138/255.0f, 138/255.0f, 141/255.0f, 1.f);
	CGContextSetLineWidth(context, 1.0);
	CGContextMoveToPoint(context, 0, rect.size.height - 1.0f);
	CGContextAddLineToPoint(context, rect.size.width, rect.size.height - 1.0f);
	CGContextStrokePath(context);
*/
	
}

#pragma mark -
#pragma mark Drawing graph

// draw graph based on ratio and order type
- (void)drawGraphRatio:(double)ratio rect:(CGRect)rect orderType:(CellOrderType)orderType{
	if (orderType == CellOrderUnits) {
		[self drawGraphRatio:ratio rect:rect colorType:GraphColorGreen];
	}
	if (orderType == CellOrderSales) {
		[self drawGraphRatio:ratio rect:rect colorType:GraphColorRed];
	}
	if (orderType == CellOrderUpgrade) {
		[self drawGraphRatio:ratio rect:rect colorType:GraphColorEmerald];
	}
}

// draw graph based on ratio and filled color
- (void)drawGraphRatio:(double)ratio rect:(CGRect)rect colorType:(GrahColorType)colorType{
	float amplitude = rect.size.width - GRAPHCELL_LEFT_GRAPH_MARGIN - GRAPHCELL_RIGHT_GRAPH_MARGIN;
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect graphFrame = CGRectMake( GRAPHCELL_LEFT_GRAPH_MARGIN, GRAPHCELL_TOP_GRAPH_MARGIN, ratio * amplitude, GRAPHCELL_GRAPH_HEIGHT);
	CGContextSaveGState(context);
	CGContextAlternativeSetShadowWithColor(context, CGSizeMake(0, -0.5), 2.0, [UIColor blackColor].CGColor);
	CGContextSetRGBFillColor( context, 0/255.0f, 0/255.0f, 0/255.0f, 1.f);
	CGContextFillRect(context, graphFrame);
	CGContextRestoreGState(context);
	
	DNSLog(@"%f", ratio);
	
	CGRect graphFrame2 = CGRectMake( GRAPHCELL_LEFT_GRAPH_MARGIN, GRAPHCELL_TOP_GRAPH_MARGIN, ratio * amplitude+1, GRAPHCELL_GRAPH_HEIGHT);
	CGContextSaveGState(context);
	CGContextClipToRect(context, graphFrame2);
	CGPoint start = CGPointMake( GRAPHCELL_LEFT_GRAPH_MARGIN, 0 );
	CGPoint end = CGPointMake( amplitude, 0 );
	CGContextDrawLinearGradient(context, TwoGraphCellGraphGradient[colorType], start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	CGContextRestoreGState(context);
}

#pragma mark -
#pragma mark Drawing string

// drawing title
- (void)drawAsTitle:(NSString*)title rect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	if (!self.originalHighlightedFlag) {
		CGContextSaveGState(context);
		CGContextAlternativeSetShadowWithColor(context, CGSizeMake(0, -1.2), 0.0, TwoGraphCellTitleShadowColor.CGColor);
	}
	if (self.originalHighlightedFlag) {
		CGContextSetRGBFillColor(context, 1.f, 1.f, 1.f, 1.f);
	}
	else {
		[TwoGraphCellTitleColor setFill];
	}
	CGSize size = [title sizeWithFont:TwoGraphCellTitleFont];
	CGRect titleRect = CGRectMake(GRAPHCELL_LEFT_TITLE_MARGIN, GRAPHCELL_TOP_TITLE_MARGIN, 0, 0);
	titleRect.size = size;
	[title drawInRect:titleRect withFont:TwoGraphCellTitleFont];

	if (!self.originalHighlightedFlag) {
		CGContextRestoreGState(context);
	}
}

- (void)drawAsValue:(NSString*)text rect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	if (!self.originalHighlightedFlag) {
		CGContextSaveGState(context);
		CGContextAlternativeSetShadowWithColor(context, CGSizeMake(0, -1.2), 0.0, TwoGraphCellValueShadowColor.CGColor);
	}
	CGContextSetRGBFillColor(context, 1.f, 1.f, 1.f, 1.f);
	CGSize size = [text sizeWithFont:TwoGraphCellValueFont];
	CGRect valueRect = CGRectMake(GRAPHCELL_LEFT_VALUE_MARGIN, GRAPHCELL_TOP_VALUE_MARGIN, 0, 0);
	valueRect.size = size;
	[text drawInRect:valueRect withFont:TwoGraphCellValueFont];
	if (!self.originalHighlightedFlag) {
		CGContextRestoreGState(context);
	}
}

#pragma mark -
#pragma mark Override

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	if (!self.originalHighlightedFlag)
		[self drawUnselectedBackgroundRect:rect];
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[super dealloc];
}

@end

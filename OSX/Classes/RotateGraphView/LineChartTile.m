//
//  LineChartTile.m
//  StoreSales
//
//  Created by sonson on 09/03/27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LineChartTile.h"
#import "LineChartData.h"
#import "GraphView.h"
#import "LineChartView.h"

UIFont *LineChartDateFont = nil;

float convertY(float y) {
	// y = 0 -> TOP_MARGIN_BOTTOM_LINE
	// y = 1 -> TOP_MARGIN_BOTTOM_LINE - GRAPH_AREA_HEIGHT
	return - GRAPH_AREA_HEIGHT * y + TOP_MARGIN_BOTTOM_LINE;
}

@implementation LineChartTile

@synthesize lineChartDataArray;
@synthesize delegate;

+ (void)initialize {
	if (LineChartDateFont == nil) {
		LineChartDateFont = [[UIFont boldSystemFontOfSize:12] retain];
	}
}

#pragma mark -
#pragma mark Override

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	DNSLogMethod
	UITouch *touch = [touches anyObject];
	if (touch.tapCount == 2) {
		[delegate swipedUp];
	}
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	int datePerView = DATE_PER_VIEW;
	int offset = 480 / datePerView /2;
	int margin = 480 / datePerView;
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextSetLineWidth(context, 2.0);
	
	UIColor *color = [LineChartView colorOfLineChart:UIAppDelegate.currentOrderType];
	
	// draw measure vertical line
	CGContextSetRGBFillColor(context, 1.f, 1.f, 1.f, 1.f);
	for (int i = 0; i < datePerView; i++ ){
		int index = indexX * datePerView + i;
		if( index < [self.lineChartDataArray count]) {
		CGContextMoveToPoint(context, offset + margin * i, TOP_MARGIN_BOTTOM_LINE-10);
		CGContextAddLineToPoint(context, offset + margin * i, TOP_MARGIN_BOTTOM_LINE);
		CGContextStrokePath(context);
		}
	}
	
	// 
	CGContextSaveGState(context);
	CGContextAlternativeSetShadowWithColor(context, CGSizeMake(0, 0), 2.0, [UIColor blackColor].CGColor);
	
	// draw measure  text
	for (int i = 0; i < datePerView; i++ ){
		int index = indexX * datePerView + i;
		if( index < [self.lineChartDataArray count]) {
			LineChartData *data = [self.lineChartDataArray objectAtIndex:index];
			if (data.value < 0) {
				CGContextSetRGBFillColor(context, 0.5f, 0.5f, 0.5f, 1.f);
			}
			else {
				CGContextSetRGBFillColor(context, 1.f, 1.f, 1.f, 1.f);
			}
			[data.dateString drawAtPoint:CGPointMake(offset + margin * i - 15, TOP_MARGIN_BOTTOM_DATE) withFont:LineChartDateFont];
		}
	}
	
	[color setFill];
	[color setStroke];
	
	CGContextSetLineWidth(context, 4.0);
	
	// search start point
	int start_index = indexX * datePerView;
	while (start_index < [self.lineChartDataArray count]) {
		LineChartData *data = [self.lineChartDataArray objectAtIndex:start_index];
		if (data.ratio > 0) {
			// found start point
			break;
		}
		start_index++;
	}
	if (start_index < [self.lineChartDataArray count]) {
		// search previous point
		int previous_index = start_index - 1;
		while (previous_index >= 0) {
			LineChartData *data = [self.lineChartDataArray objectAtIndex:previous_index];
			if (data.ratio > 0) {
				// found start point
				break;
			}
			previous_index--;
		}
		
		if (previous_index >= 0 ) {
			LineChartData *data1 = [self.lineChartDataArray objectAtIndex:start_index];
			LineChartData *data2 = [self.lineChartDataArray objectAtIndex:previous_index];
			
			float y1 = convertY(data1.ratio);
			float y2 = convertY(data2.ratio);
		//	CGContextSetRGBStrokeColor(context, 0.f, 0.f, 1.f, 1.f);
			CGContextMoveToPoint(context, offset + margin * (start_index - indexX * datePerView), y1);
			CGContextAddLineToPoint(context, offset + margin * (previous_index - indexX * datePerView), y2);
			CGContextStrokePath(context);
		}
		
		//CGContextSetRGBStrokeColor(context, 1.f, 1.f, 0.f, 1.f);
		if (start_index < (indexX + 1) * datePerView) {
			int next_index = start_index + 1;
			if (next_index < [self.lineChartDataArray count]) {
				LineChartData *data1 = [self.lineChartDataArray objectAtIndex:start_index];
				float y1 = convertY(data1.ratio);
				CGContextMoveToPoint(context, offset + margin * (start_index - indexX * datePerView), y1);
				while (next_index < [self.lineChartDataArray count]) {
					LineChartData *data2 = [self.lineChartDataArray objectAtIndex:next_index];
					if (data2.ratio > 0) {
						// found start point
						float y2 = convertY(data2.ratio);
						CGContextAddLineToPoint(context, offset + margin * (next_index - indexX * datePerView), y2);
						if (next_index >= (indexX + 1) * datePerView) {
							break;
						}
					}
					next_index++;
				}
			}
		}
		CGContextStrokePath(context);
	}
	
	// draw data point
	for (int i = 0; i < datePerView; i++ ){
		int index = indexX * datePerView + i;
		if( index < [self.lineChartDataArray count]) {
			LineChartData *data = [self.lineChartDataArray objectAtIndex:index];
			
			if (data.ratio > 0) {
				float radius = 14;
				//	CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
				CGContextSetLineWidth(context, 2.0);
				float x = offset + margin * i;
				float y = convertY(data.ratio);
				CGContextAddEllipseInRect(context, CGRectMake(x-radius/2, y-radius/2, radius, radius));
				CGContextFillPath(context);
			}
		}
	}
	
	CGContextRestoreGState(context);
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[delegate release];
    [super dealloc];
}

@end

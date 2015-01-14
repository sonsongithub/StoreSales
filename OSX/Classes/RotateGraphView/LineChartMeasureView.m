//
//  LineChartMeasureView.m
//  StoreSales
//
//  Created by sonson on 09/03/27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LineChartMeasureView.h"
#import "LineChartTile.h"

UIFont *LineChartMeasureFont = nil;

@implementation LineChartMeasureView

@synthesize measureMaxString;
@synthesize measureMidString;
@synthesize measureUnitString;

+ (void)initialize {
	if (LineChartMeasureFont == nil) {
		LineChartMeasureFont = [[UIFont boldSystemFontOfSize:12] retain];
	}
}

#pragma mark -
#pragma mark Class Method

+ (LineChartMeasureView*)defaultView {
	LineChartMeasureView* view = [[LineChartMeasureView alloc] initWithFrame:CGRectMake(0, 0, 50, 300)];
	view.backgroundColor = [UIColor clearColor];
	return [view autorelease];
}

#pragma mark -
#pragma mark Drawing method

- (void)setupMeasureString:(float)value {
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	self.measureMaxString = [formatter stringFromNumber:[NSNumber numberWithInt:(int)value]];
	self.measureMidString = [formatter stringFromNumber:[NSNumber numberWithInt:(int)value/2]];
	
	if (UIAppDelegate.currentOrderType == CellOrderSales) {
		self.measureUnitString = [NSString stringWithFormat:@"(%@)", UIAppDelegate.currencyDescription];
	}
	else {
		self.measureUnitString = nil;//[NSString stringWithFormat:NSLocalizedString(@"(Units)", nil)];
	}
	CGSize sizeMaxString = [self.measureMaxString sizeWithFont:LineChartMeasureFont];
	CGSize sizeMidString = [self.measureMidString sizeWithFont:LineChartMeasureFont];
	CGSize sizeUnitString = [self.measureUnitString sizeWithFont:LineChartMeasureFont];
	
	CGRect rect = self.frame;
	if (sizeMaxString.width > sizeMidString.width) {
		if (sizeMaxString.width > sizeUnitString.width) {
			rect.size.width = sizeMaxString.width;
		}
		else {
			rect.size.width = sizeUnitString.width;
		}
	}
	else {
		if (sizeMidString.width > sizeUnitString.width) {
			rect.size.width = sizeMidString.width;
		}
		else {
			rect.size.width = sizeUnitString.width;
		}
	}
	rect.size.width += 10;
	rect.origin.x = -rect.size.width;
	self.frame = rect;
}

- (void)drawMeasureRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(context, 1.f, 1.f, 1.f, 1.f);
	
	CGSize sizeMaxString = [self.measureMaxString sizeWithFont:LineChartMeasureFont];
	CGSize sizeMidString = [self.measureMidString sizeWithFont:LineChartMeasureFont];
	CGSize sizeUnitString = [self.measureUnitString sizeWithFont:LineChartMeasureFont];
	
	[self.measureMaxString drawAtPoint:CGPointMake((int)(rect.size.width-sizeMaxString.width)/2, (int)convertY(1.0) - 8) withFont:LineChartMeasureFont];
	[self.measureMidString drawAtPoint:CGPointMake((int)(rect.size.width-sizeMidString.width)/2, (int)convertY(0.5) - 8) withFont:LineChartMeasureFont];
	[self.measureUnitString drawAtPoint:CGPointMake((int)(rect.size.width-sizeUnitString.width)/2, 0) withFont:LineChartMeasureFont];
}

#pragma mark -
#pragma mark Override

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(context, 0.f, 0.f, 0.f, 0.75);
	CGContextFillRect(context, rect);
	[self drawMeasureRect:rect];
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[measureMaxString release];
	[measureMidString release];
	[measureUnitString release];
    [super dealloc];
}


@end

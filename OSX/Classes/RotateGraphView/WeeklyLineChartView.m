//
//  DailyLineChartView.m
//  StoreSales
//
//  Created by sonson on 09/03/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WeeklyLineChartView.h"
#import "PeriodicalSales.h"
#import "LineChartData.h"

@implementation WeeklyLineChartView

@synthesize tableViewController;

#pragma mark -
#pragma mark Original method

- (void)willUpdateData {
	[self.tableViewController toggleButtonbar:YES];
	[self updateData];
}

- (void)updateData {
	// dummy
	self.chartData = [NSMutableArray array];
	if ([self.chartData count] > 0) {
		return;
	}
	
	NSMutableArray* temp = self.tableViewController.cells;

	for (int i = [temp count] - 1; i >= 0; i--) {
		PeriodicalSales *sales = [temp objectAtIndex:i];
		
		// insert
		LineChartData *data = [[LineChartData alloc] init];
		data.timeInterval = [sales.beginDate timeIntervalSinceReferenceDate];
		data.ratio = sales.ratio;
		data.value = sales.value;
		[self.chartData addObject:data];
		[data release];
		
		NSTimeInterval interval = 3600 * 24 * 7;
		int j = 1;
		NSTimeInterval currentTime = [sales.beginDate timeIntervalSinceReferenceDate];
		
		if (i == 0) {
			// last data
			break;
		}
	
		PeriodicalSales *prevSales = [temp objectAtIndex:i-1];
		NSTimeInterval prevTime = [prevSales.beginDate timeIntervalSinceReferenceDate];
		
		while(prevTime > currentTime + interval * j) {
			LineChartData *data = [[LineChartData alloc] init];
			data.timeInterval = (int)(currentTime + interval * j);
			data.ratio = -1;
			data.value = -1;
			[self.chartData addObject:data];
			[data release];
			j++;
		}
	}

	self.title = [self.tableViewController titleForLineChart];
	self.subtitle = [self.tableViewController subtitleForLineChart];
	[self setNeedsDisplay];
	[self updateMaxValue];
	[self setupMeasureView];
	[self rebuildContentSizeAndTiles];
}

#pragma mark -
#pragma mark Override

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[tableViewController release];
    [super dealloc];
}

@end

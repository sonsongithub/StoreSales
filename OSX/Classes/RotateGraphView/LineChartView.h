//
//  LineChartView.h
//  StoreSales
//
//  Created by sonson on 09/03/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"

@class LineChartMeasureView;

@interface LineChartView : GraphView <UIScrollViewDelegate> {
	NSMutableArray			*chartData;
	UIScrollView			*baseScrollView;
	NSMutableArray			*views;
	float					max_value_measure;
	LineChartMeasureView	*measureView;
	NSString				*title;
	NSString				*subtitle;
	UIActivityIndicatorView	*indicator;
}
@property (nonatomic, retain) NSMutableArray *chartData;
@property (nonatomic, retain) NSMutableArray *views;
@property (nonatomic, retain) UIScrollView *baseScrollView;
@property (nonatomic, retain) LineChartMeasureView *measureView;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
#pragma mark Original method
- (void)updateData;
- (void)swipedUp;
- (void)setupMeasureView;
- (void)rebuildContentSizeAndTiles;
- (void)updateMaxValue;
+ (UIColor*)colorOfLineChart:(CellOrderType)orderType;
@end

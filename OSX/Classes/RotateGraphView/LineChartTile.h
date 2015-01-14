//
//  LineChartTile.h
//  StoreSales
//
//  Created by sonson on 09/03/27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tile.h"

#define TOP_MARGIN_BOTTOM_DATE	280
#define TOP_MARGIN_BOTTOM_LINE	275
#define GRAPH_AREA_HEIGHT		240

#define DATE_PER_VIEW			12

float convertY(float y);

@class GraphView;

@interface LineChartTile : Tile {
	NSMutableArray	*lineChartDataArray;
	NSTimeInterval	gestureStartTimeStamp;
	CGPoint			gestureStartPoint;
	GraphView		*delegate;
}
@property (nonatomic, retain) NSMutableArray* lineChartDataArray;
@property (nonatomic, retain) GraphView* delegate;
@end

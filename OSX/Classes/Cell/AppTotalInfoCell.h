//
//  AppTotalInfoCell.h
//  StoreSales
//
//  Created by sonson on 09/02/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNCellForDrawRect.h"
#import "AppInfoCell.h"

#define LEFT_MARGIN_CIRCLE_GRAPH		8
#define TOP_MARGIN_CIRCLE_GRAPH			6
#define RADIUS_CIRCLE_GRAPH				40
#define RADIUS_CIRCLE_ICON				25

#define CENTER_X_CIRCLE_GRAPH			(LEFT_MARGIN_CIRCLE_GRAPH + RADIUS_CIRCLE_GRAPH)
#define CENTER_Y_CIRCLE_GRAPH			(TOP_MARGIN_CIRCLE_GRAPH + RADIUS_CIRCLE_GRAPH)

#define ICON_WIDTH_CIRCLE_GRAPH			20
#define ICON_HEIGHT_CIRCLE_GRAPH		20

@interface AppTotalInfoCell : SNCellForDrawRect {
	NSMutableArray			*appInfoArray;
	CellOrderType			orderType;
}
@property (nonatomic, retain) NSMutableArray *appInfoArray;
@property (nonatomic, assign) CellOrderType orderType;
+ (float)height;
@end

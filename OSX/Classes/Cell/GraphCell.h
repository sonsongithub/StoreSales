//
//  TwoGraphCell.h
//  StoreSales
//
//  Created by sonson on 09/03/06.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNCellForDrawRect.h"

typedef enum {
	GraphColorBlue,
	GraphColorGreen,
	GraphColorEmerald,
	GraphColorPerple,
	GraphColorRed,
	GraphColorGray
}GrahColorType;

#define GRAPH_COLOR_COUNT 6

@interface GraphCell : SNCellForDrawRect {
	BOOL			odd;
}
@property (nonatomic, assign) BOOL odd;
- (void)drawUnselectedBackgroundRect:(CGRect)rect;
- (void)drawGraphRatio:(double)ratio rect:(CGRect)rect colorType:(GrahColorType)colorType;
- (void)drawGraphRatio:(double)ratio rect:(CGRect)rect orderType:(CellOrderType)orderType;
- (void)drawAsTitle:(NSString*)title rect:(CGRect)rect;
- (void)drawAsValue:(NSString*)text rect:(CGRect)rect;
@end

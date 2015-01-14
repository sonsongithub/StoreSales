//
//  CircleGraphView.h
//  StoreSales
//
//  Created by sonson on 09/03/15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"

#define RADIUS_ROTATE_CIRCLE_GRAPH			120
#define RADIUS_ROTATE_CIRCLE_ICON			80

#define CENTER_X_ROTATE_CIRCLE_GRAPH		300		//(LEFT_MARGIN_ROTATE_CIRCLE_GRAPH + RADIUS_ROTATE_CIRCLE_GRAPH)
#define CENTER_Y_ROTATE_CIRCLE_GRAPH		150		//(TOP_MARGIN_ROTATE_CIRCLE_GRAPH + RADIUS_ROTATE_CIRCLE_GRAPH)

#define RADIUS_ROTATE_CIRCLE_GRAPH_LINE		130
#define RADIUS_ROTATE_CIRCLE_GRAPH_TEXT		140

#define ICON_WIDTH_ROTATE_CIRCLE_GRAPH		20
#define ICON_HEIGHT_ROTATE_CIRCLE_GRAPH		20

#define RADIUS_ROTATE_CIRCLE_COVER			120

@interface CircleGraphView : GraphView {
	NSTimer						*animationTimer;
	float						deg;
}
@property (nonatomic, retain) NSTimer *animationTimer;
- (void)drawGraphRect:(CGRect)rect;
- (void)drawAnimationWithClippingRect:(CGRect)rect;
- (void)redraw:(NSTimer*)theTimer;
- (void)startAnimationTimer;
- (void)drawNoDataMessageRect:(CGRect)rect;
- (void)didFinishAnimation;
@end

//
//  AppTotalGraphView.h
//  StoreSales
//
//  Created by sonson on 09/03/08.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"
#import "TotalTableViewController.h"
#import "CircleGraphView.h"

@interface AppTotalGraphView : CircleGraphView {
	NSMutableArray				*cells;
	TotalTableViewController*	tableViewController;
	NSString					*graphTitle;
	NSString					*graphTotalText;
}
@property (nonatomic, retain) NSMutableArray *cells;
@property (nonatomic, retain) TotalTableViewController *tableViewController;
@property (nonatomic, retain) NSString *graphTitle;
@property (nonatomic, retain) NSString *graphTotalText;
#pragma mark Gesture delegate method
- (void)swipedUp;
- (void)swipedDown;
#pragma mark Drawing
- (void)drawGraphText:(CGRect)rect;
- (void)drawGraphRect:(CGRect)rect;
- (void)drawIconInGraphRect:(CGRect)rect;
- (void)drawDescriptionInGraphRect:(CGRect)rect;
@end

//
//  CountriesTotalGraphView.h
//  StoreSales
//
//  Created by sonson on 09/03/15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryTableViewController.h"
#import "GraphView.h"
#import "CircleGraphView.h"

@interface CountriesTotalGraphView : CircleGraphView {
	NSMutableArray				*cells;
	CountryTableViewController*	tableViewController;
	NSString					*graphTitle;
	NSString					*graphTotalText;
}
@property (nonatomic, retain) NSMutableArray *cells;
@property (nonatomic, retain) CountryTableViewController *tableViewController;
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
- (void)setInfoArray:(NSMutableArray*)input;
@end

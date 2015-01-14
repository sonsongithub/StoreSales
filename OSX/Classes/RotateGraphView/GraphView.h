//
//  GraphView.h
//  StoreSales
//
//  Created by sonson on 09/03/08.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphView : UIView {
	NSTimeInterval	gestureStartTimeStamp;
	CGPoint			gestureStartPoint;
}
- (void)swipedUp;
- (void)swipedDown;
- (void)startAnimationTimer;
- (void)startToAppear;
- (void)startToDisappear;
@end

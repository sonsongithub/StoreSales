//
//  PageButtonController.h
//  StoreSales
//
//  Created by sonson on 09/10/07.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PageButtonController;

@protocol PageButtonControllerDelegate <NSObject>
- (void)didPageUp:(PageButtonController*)controller;
- (void)didPageDown:(PageButtonController*)controller;
@end


@interface PageButtonController : NSObject {
	UISegmentedControl *segmentControl;
	id <PageButtonControllerDelegate> delegate;
}
@property (nonatomic, readonly) UISegmentedControl *segmentControl;
- (id)initWithDelegate:(id<PageButtonControllerDelegate>)theDelegate;
- (void)upButtonEnabled:(BOOL)value;
- (void)downButtonEnabled:(BOOL)value;
- (void)updateState:(int)current max:(int)max;
@end

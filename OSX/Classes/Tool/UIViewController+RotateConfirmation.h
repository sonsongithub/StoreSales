//
//  UIViewController+RotateConfirmation.h
//  StoreSales
//
//  Created by sonson on 09/03/08.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@interface UIViewController(RotateConfirmation)
- (BOOL)haveRotateView;
- (GraphView*)graphView;
@end

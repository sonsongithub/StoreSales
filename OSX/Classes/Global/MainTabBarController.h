//
//  MainTabBarController.h
//  StoreSales
//
//  Created by sonson on 09/02/24.
//  Copyright 2009 sonson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@interface MainTabBarController : UITabBarController {
	UITabBar			*tabBar;
	
	UIView				*blackout;
	
	GraphView			*rotatedView;
	BOOL				isShowingLandscapeView;
	UIInterfaceOrientation
						previousMode;
}
+ (NSArray*)defaultNavigationControllers;
@end

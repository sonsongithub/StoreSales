//
//  MainTabBarController.m
//  StoreSales
//
//  Created by sonson on 09/02/24.
//  Copyright 2009 sonson. All rights reserved.
//

#import "MainTabBarController.h"

#import "AppViewController.h"
#import "DailyViewController.h"
#import "WeeklyViewController.h"
#import "CountiresViewController.h"
#import "UIViewController+TabBarItem.h"
#import "SNTableViewController.h"

#import "TotalTableViewController.h"
#import "DailyTableViewController.h"

#import "UIViewController+RotateConfirmation.h"
#import "GraphView.h"

#import "UIDevice+StoreSales.h"

typedef enum {
	PortraitMode	= 0,
	LandscapeMode	= 1,
	UnknownMode		= 2,
}OrientationMode;

OrientationMode getOrientationMode(UIDeviceOrientation orientation) {
	if (orientation == UIDeviceOrientationLandscapeLeft) {
		return LandscapeMode;
	}
	else if (orientation == UIDeviceOrientationLandscapeRight) {
		return LandscapeMode;
	}
	else if (orientation == UIDeviceOrientationPortrait) {
		return PortraitMode;
	}
	else if (orientation == UIDeviceOrientationPortraitUpsideDown) {
		return PortraitMode;
	}
	return UnknownMode;
}

@implementation MainTabBarController

#pragma mark -
#pragma mark Make viewcontrollers

+ (NSArray*)defaultNavigationControllers {
	NSMutableArray* navigationControllers = [NSMutableArray array];
	
	NSMutableArray *viewControllerClasses = [[NSMutableArray alloc] init];
	[viewControllerClasses addObject:[AppViewController class]];
	[viewControllerClasses addObject:[DailyViewController class]];
	[viewControllerClasses addObject:[WeeklyViewController class]];
	[viewControllerClasses addObject:[CountiresViewController class]];
	
	// based on same class
	for (Class viewControllerClass in viewControllerClasses ) {
		SNTableViewController *rootViewController = [[[viewControllerClass alloc] initWithStyle:UITableViewStylePlain] autorelease];
		UINavigationController *naviCon = [[[UINavigationController alloc] initWithRootViewController:rootViewController] autorelease];
		[rootViewController setTabBarItemToParentNavigationController];
		[navigationControllers addObject:naviCon];
	}
	
	[viewControllerClasses release];
	return navigationControllers;
}

#pragma mark -
#pragma mark UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
	DNSLogMethod
}

#pragma mark -
#pragma mark Override

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	self = [super initWithNibName:nibName bundle:nibBundle];
	[self rotatingFooterView].backgroundColor = [UIColor blackColor];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)
												 name:UIDeviceOrientationDidChangeNotification object:nil];	
	
	blackout = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 480)];
	blackout.backgroundColor = [UIColor blackColor];
	[UIAppDelegate.window addSubview:blackout];
	
	return self;
}

#pragma mark -
#pragma mark For orientation

- (void)orientationChanged:(NSNotification *)notification {
	UIDeviceOrientation orientation = [[notification object] orientation];
	
	OrientationMode currentMode = getOrientationMode(orientation);
	
	//
	// Check if the top visible view has rotated graph view
	//
	UINavigationController *naviCon = (UINavigationController *)[self selectedViewController];
	UIViewController *con = [naviCon visibleViewController];
	if (![con haveRotateView]) {
		return;
	}
	
	DNSLog(@"%@=>%@", [UIDevice descriptionOfOrientation:previousMode], [UIDevice descriptionOfOrientation:currentMode]);
	
	if (currentMode == PortraitMode && previousMode == LandscapeMode) {
		
		blackout.alpha = 0;
		[UIView beginAnimations:@"1" context:nil];
		blackout.alpha = 1;
		[UIView commitAnimations];
		
		[self rotatingFooterView].hidden = NO;
		[self rotatingHeaderView].hidden = NO;
		
		//
		// Start orientation animation
		//
		[self performSelector:@selector(updateLandscapeView) withObject:nil afterDelay:0.4];
		previousMode = currentMode;
	}
	else if (currentMode == LandscapeMode && previousMode == PortraitMode) {
		
		blackout.alpha = 0;
		[UIView beginAnimations:@"1" context:nil];
		blackout.alpha = 1;
		[UIView commitAnimations];
		
		[self rotatingFooterView].hidden = YES;
		[self rotatingHeaderView].hidden = YES;
		
		//
		// Start orientation animation
		//
		[self performSelector:@selector(updateLandscapeView) withObject:nil afterDelay:0.4];
		previousMode = currentMode;
	}
}

- (void)updateLandscapeView {
	//
	// Check if the top visible view has rotated graph view
	//
	UINavigationController *naviCon = (UINavigationController *)[self selectedViewController];
	UIViewController *con = [naviCon visibleViewController];
	if (![con haveRotateView]) {
		return;
	}
	
	//
	// Rotation
	//
	if (isShowingLandscapeView) {
		
		//
		// Back to portrait mode
		//
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
		[rotatedView removeFromSuperview];
		rotatedView = nil;
		isShowingLandscapeView = NO;
	}
	else {
		//
		// Move to landscape mode
		//
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
		rotatedView = [con graphView];		
		CGRect frame = rotatedView.frame;
		frame.origin.y = 20;
		frame.size.height = 300;
		rotatedView.frame = frame;
		[self.view addSubview:rotatedView];
		isShowingLandscapeView = YES;
	}
	
	//
	// Fadein
	//
	[UIAppDelegate.window addSubview:blackout];
	[UIView beginAnimations:@"1" context:nil];
	blackout.alpha = 0;
	[UIView commitAnimations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	DNSLogMethod
	DNSLog(@"shouldAutorotateToInterfaceOrientation %d", interfaceOrientation);
	DNSLog(@"UIDevice->shouldAutorotateToInterfaceOrientation %d", [UIDevice currentDevice].orientation);
	
	UINavigationController *naviCon = (UINavigationController *)[self selectedViewController];
	UIViewController *con = [naviCon visibleViewController];
	if ([con haveRotateView]) {
		return YES;
	}
	return NO;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	UIDevice *device = [UIDevice currentDevice];
	[device endGeneratingDeviceOrientationNotifications];
    [super dealloc];
}

@end

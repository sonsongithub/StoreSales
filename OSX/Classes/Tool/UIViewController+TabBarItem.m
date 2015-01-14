//
//  UIViewController+TabBarItem.m
//  StoreSales
//
//  Created by sonson on 09/02/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+TabBarItem.h"

#import "InfoViewController.h"
#import "TutorialPageController.h"
#import "SyncViewController.h"

@implementation UIViewController(TabBarItem)

- (void)setTabBarItemToParentNavigationController {
	// this is dummy
}

- (void)openSyncWithTutorial {	
	TutorialPageController *tutorialViewCon = [[[TutorialPageController alloc] init] autorelease];
	UINavigationController *tutorialViewNav = [[[UINavigationController alloc] initWithRootViewController:tutorialViewCon] autorelease];
	[self presentModalViewController:tutorialViewNav animated:YES];
}

- (void)openSync:(id)sender {
	UINavigationController *nav = [SyncViewController defaultController];
	[self.navigationController presentModalViewController:nav animated:YES];
}

- (void)openInfo:(id)sender {
	UINavigationController* con = [InfoViewController controllerWithNavigationController];
	[self.navigationController presentModalViewController:con animated:YES];
}

- (void)setNavigationItem {
	// for open setting and sync view controller
	UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sync", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(openSync:)];
	self.navigationItem.rightBarButtonItem = reloadButton;
	[reloadButton release];
	
	UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Info", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(openInfo:)];
	self.navigationItem.leftBarButtonItem = infoButton;
	[infoButton release];
}

@end

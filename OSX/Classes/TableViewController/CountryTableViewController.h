//
//  CountryTableViewController.h
//  StoreSales
//
//  Created by sonson on 09/03/05.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+TabBarItem.h"
#import "SNTableViewController.h"
#import "SNButtonBar.h"

@interface CountryTableViewController : SNTableViewController {
	NSMutableArray		*cells;
	UIImageView			*backgroundImageView;
//	CellOrderType		orderType;
	SNButtonBar			*buttonbar;
}
@property (nonatomic, retain) NSMutableArray *cells;
@property (nonatomic, retain) UIImageView *backgroundImageView;
@property (nonatomic, retain) SNButtonBar *buttonbar;
- (void)toggleButtonbar:(BOOL)forwarding;
- (NSString*)graphTitle;
- (NSString*)graphTotalText;
@end

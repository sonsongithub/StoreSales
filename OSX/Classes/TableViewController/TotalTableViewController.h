//
//  TotalViewController.h
//  StoreSales
//
//  Created by sonson on 09/03/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTableViewController.h"
#import "SNButtonBar.h"
#import "AppTotalInfoCell.h"
#import "AppInfoCell.h"
#import "PageButtonController.h"

@interface TotalTableViewController : SNTableViewController <PageButtonControllerDelegate> {
	NSMutableArray			*cells;
	UIImageView				*backgroundImageView;
	SNButtonBar				*buttonbar;
	PageButtonController	*pageButtonController;
	int						selectedRow;
	NSMutableArray			*parentCells;
}
@property (nonatomic, retain) NSMutableArray *cells;
@property (nonatomic, retain) NSMutableArray *parentCells;
@property (nonatomic, assign) int selectedRow;
@property (nonatomic, retain) UIImageView *backgroundImageView;
@property (nonatomic, retain) SNButtonBar *buttonbar;
- (NSString*)graphTitle;
- (NSString*)graphTotalText;
- (void)toggleButtonbar:(BOOL)forwarding;
- (void)updateSelectedRow;
@end

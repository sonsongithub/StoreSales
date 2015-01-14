//
//  SNButtonBar.h
//  StoreSales
//
//  Created by sonson on 09/02/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNButtonBar;

@protocol SNButtonBarDelegate
- (void)buttonBar:(SNButtonBar*)buttonBar didChangeSelectedIndex:(int)selectedIndex;
@end

@interface SNButtonBar : UIView {
	int						selectedIndex;
	NSMutableArray			*buttons;
	id						delegate;
}
@property (nonatomic, readonly, assign) int selectedIndex;
@property (nonatomic, retain) NSMutableArray *buttons;
@property (nonatomic, retain) id delegate;
#pragma mark Class method
+ (SNButtonBar*)buttonBarWithTitles:(NSArray*)titles;
#pragma mark Instance method
- (void)setSelectedIndexWithCellOrderType:(CellOrderType)orderType;
- (void)setSelectedIndex:(int)newValue;
- (void)pushButton:(id)sender;
- (void)setupWithTitles:(NSArray*)titles;
@end

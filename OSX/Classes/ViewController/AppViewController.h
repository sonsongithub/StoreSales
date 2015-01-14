//
//  AppViewController.h
//  StoreSales
//
//  Created by sonson on 09/02/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TotalTableViewController.h"
#import "UIViewController+TabBarItem.h"
#import "AppInfoCell.h"
#import "GraphView.h"

@interface AppViewController : TotalTableViewController {
}
- (NSString*)pathCachePlistOfTOrderType:(CellOrderType)type;
- (BOOL)readCellPlistOfOrderType:(CellOrderType)type;
- (BOOL)writeCellPlistOfOrderType:(CellOrderType)type;
- (void)selectFromSQLiteOrderType:(CellOrderType)type;
- (void)updateTitle;
- (void)reload;
@end

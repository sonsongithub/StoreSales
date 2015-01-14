//
//  WeeklyViewController.h
//  StoreSales
//
//  Created by sonson on 09/02/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeeklyTableViewController.h"

@interface WeeklyViewController : WeeklyTableViewController {
}
- (NSString*)pathCachePlistOfTOrderType:(CellOrderType)type;
- (BOOL)readCellPlistOfOrderType:(CellOrderType)type;
- (BOOL)writeCellPlistOfOrderType:(CellOrderType)type;
- (void)selectFromSQLiteOrderType:(CellOrderType)type;
- (void)reload;
@end

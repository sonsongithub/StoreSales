//
//  AppInfoCell.h
//  StoreSales
//
//  Created by sonson on 09/02/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphCell.h"

@class ApplicationSales;

@interface AppInfoCell : GraphCell {
	ApplicationSales	*sales;
	CellOrderType		orderType;
}
@property (nonatomic, retain) ApplicationSales *sales;
@property (nonatomic, assign) CellOrderType orderType;
@end

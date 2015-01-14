//
//  CountryCell.h
//  StoreSales
//
//  Created by sonson on 09/03/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GraphCell.h"
#import "CountrySales.h"
#import "SNCellForDrawRect.h"

@interface CountryCell : GraphCell {
	CountrySales	*sales;
	CellOrderType	orderType;
}
@property (nonatomic, retain) CountrySales *sales;
@property (nonatomic, assign) CellOrderType orderType;
@end

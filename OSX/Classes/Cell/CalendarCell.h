//
//  CalendarCell.h
//  StoreSales
//
//  Created by sonson on 09/03/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GraphCell.h"
#import "SNCellForDrawRect.h"
#import "PeriodicalSales.h"

@interface CalendarCell : GraphCell {
	PeriodicalSales	*sales;
	CellOrderType	orderType;
}
@property (nonatomic, retain) PeriodicalSales *sales;
@property (nonatomic, assign) CellOrderType orderType;
- (void)drawCalendarRect:(CGRect)rect upperString:(NSString*)upperString lowerString:(NSString*)lowerString;
@end

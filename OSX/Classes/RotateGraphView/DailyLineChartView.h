//
//  DailyLineChartView.h
//  StoreSales
//
//  Created by sonson on 09/03/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LineChartView.h"
#import "DailyTableViewController.h"

@interface DailyLineChartView : LineChartView {
	DailyTableViewController *tableViewController;
}
@property (nonatomic, retain) DailyTableViewController *tableViewController;
@end

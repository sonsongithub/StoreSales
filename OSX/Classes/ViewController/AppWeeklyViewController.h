//
//  AppWeeklyViewController.h
//  StoreSales
//
//  Created by sonson on 09/03/07.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeeklyTableViewController.h"
#import "ApplicationInfo.h"
#import "ApplicationSales.h"

@interface AppWeeklyViewController : WeeklyTableViewController {
	ApplicationSales	*currentSales;
//	int currentAppleIdentifier;
}
@property (nonatomic, retain) ApplicationSales* currentSales;
//@property (nonatomic, assign) int currentAppleIdentifier;
@end
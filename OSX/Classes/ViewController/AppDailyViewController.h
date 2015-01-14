//
//  AppDailyViewController.h
//  StoreSales
//
//  Created by sonson on 09/03/07.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DailyTableViewController.h"
#import "ApplicationInfo.h"
#import "ApplicationSales.h"

@interface AppDailyViewController : DailyTableViewController {
	ApplicationSales	*currentSales;
//	int					currentAppleIdentifier;
}
@property (nonatomic, retain) ApplicationSales* currentSales;
//@property (nonatomic, assign) int currentAppleIdentifier;
@end

//
//  SelectOrderViewController.h
//  StoreSales
//
//  Created by sonson on 09/03/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTableViewController.h"
#import "ApplicationInfo.h"
#import "ApplicationSales.h"

@interface SelectOrderViewController : SNTableViewController {
	ApplicationSales* sales;
	int	appleIdentifier;
}
@property (nonatomic, retain) ApplicationSales* sales;
@property (nonatomic, assign) int appleIdentifier;
@end

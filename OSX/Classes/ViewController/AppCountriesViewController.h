//
//  AppCountriesViewController.h
//  StoreSales
//
//  Created by sonson on 09/03/07.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryTableViewController.h"
#import "ApplicationInfo.h"
#import "ApplicationSales.h"

@interface AppCountriesViewController : CountryTableViewController {
	ApplicationSales	*currentSales;
}
@property (nonatomic, retain) ApplicationSales* currentSales;
@end
//
//  CountriesTotalViewController.h
//  StoreSales
//
//  Created by sonson on 09/03/07.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TotalTableViewController.h"
#import "CountryInfo.h"

@interface CountriesTotalViewController : TotalTableViewController {
	NSString *currentCountryCode;
	CountryInfo* info;
}
@property (nonatomic, retain) NSString *currentCountryCode;
@property (nonatomic, retain) CountryInfo *info;
@end

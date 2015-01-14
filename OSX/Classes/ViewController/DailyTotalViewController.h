//
//  DailyTotalViewController.h
//  StoreSales
//
//  Created by sonson on 09/03/07.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TotalTableViewController.h"

@interface DailyTotalViewController : TotalTableViewController {
	NSDate					*currentBeginDate;
	NSDate					*currentEndDate;
}
@property (nonatomic, retain) NSDate *currentBeginDate;
@property (nonatomic, retain) NSDate *currentEndDate;
@end

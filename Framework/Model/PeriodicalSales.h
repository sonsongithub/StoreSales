//
//  DailySales.h
//  StoreSales
//
//  Created by sonson on 09/03/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PeriodicalSales : NSObject {
	// data identifier
	NSString			*dateIdentifier;
	// raw data for drawing
	double				ratio;
	double				value;
	NSString			*valueString;
	// date info
	NSDate				*beginDate;
	NSDate				*endDate;
	// date string for drawing on a cell
	NSString			*dateString;
	NSString			*dateWeekString;
	NSString			*monthString;
	NSString			*beginDateString;
	NSString			*endDateString;
	NSString			*periodicalString;
}
@property (nonatomic, retain) NSString	*dateIdentifier;
@property (nonatomic, retain) NSDate	*beginDate;
@property (nonatomic, retain) NSDate	*endDate;
@property (nonatomic, retain) NSString	*dateString;
@property (nonatomic, retain) NSString	*dateWeekString;
@property (nonatomic, retain) NSString	*monthString;
@property (nonatomic, retain) NSString	*beginDateString;
@property (nonatomic, retain) NSString	*endDateString;
@property (nonatomic, retain) NSString	*periodicalString;
@property (nonatomic, assign) double	value;
@property (nonatomic, assign) double	ratio;
@property (nonatomic, retain) NSString	*valueString;

+ (PeriodicalSales*)PeriodicalSalesFromFile:(FILE*)fp;
- (int)write:(FILE*)fp;
- (int)read:(FILE*)fp;

@end

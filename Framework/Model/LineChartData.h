//
//  LineChartData.h
//  StoreSales
//
//  Created by sonson on 09/03/27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LineChartData : NSObject {
	NSTimeInterval	timeInterval;
	NSDate			*date;
	NSString		*dateString;
	float			ratio;
	float			value;
}
@property (nonatomic, readonly) NSDate			*date;
@property (nonatomic, readonly) NSString		*dateString;
@property (nonatomic, assign) NSTimeInterval	timeInterval;
@property (nonatomic, assign) float				ratio;
@property (nonatomic, assign) float				value;
@end

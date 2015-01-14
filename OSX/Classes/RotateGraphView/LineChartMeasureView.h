//
//  LineChartMeasureView.h
//  StoreSales
//
//  Created by sonson on 09/03/27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LineChartMeasureView : UIView {
	NSString		*measureMaxString;
	NSString		*measureMidString;
	NSString		*measureUnitString;
}
@property (nonatomic, retain) NSString* measureMaxString;
@property (nonatomic, retain) NSString* measureMidString;
@property (nonatomic, retain) NSString* measureUnitString;
#pragma mark Class Method
+ (LineChartMeasureView*)defaultView;
#pragma mark Drawing method
- (void)setupMeasureString:(float)value;
- (void)drawMeasureRect:(CGRect)rect;
@end

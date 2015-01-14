//
//  Sales.h
//  StoreSales
//
//  Created by sonson on 09/02/26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ApplicationInfo;

@interface ApplicationSales : NSObject {
	ApplicationInfo		*info;
	double				value;
	double				ratio;
	NSString			*valueString;
	NSString			*applicationIdentifierString;
}
@property (nonatomic, retain) ApplicationInfo *info;
@property (nonatomic, assign) double value;
@property (nonatomic, assign) double ratio;
@property (nonatomic, retain) NSString *valueString;
@property (nonatomic, retain) NSString *applicationIdentifierString;

+ (ApplicationSales*)ApplicationSalesFromFile:(FILE*)fp;
- (void)write:(FILE*)fp;
- (BOOL)read:(FILE*)fp;

@end

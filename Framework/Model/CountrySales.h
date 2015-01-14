//
//  CountrySales.h
//  StoreSales
//
//  Created by sonson on 09/03/03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CountryInfo.h"

@interface CountrySales : NSObject {
	// Country Info
	CountryInfo			*info;
	
	// raw data 
	double				ratio;
	double				value;
	NSString			*valueString;
	NSString			*countryCode;
}
@property (nonatomic, retain) CountryInfo *info;
@property (nonatomic, assign) double value;
@property (nonatomic, assign) double ratio;
@property (nonatomic, retain) NSString *valueString;
@property (nonatomic, retain) NSString *countryCode;

+ (CountrySales*)CountrySalesFromFile:(FILE*)fp;
- (void)write:(FILE*)fp;
- (void)read:(FILE*)fp;

@end

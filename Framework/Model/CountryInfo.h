//
//  FlagController.h
//  StoreSales
//
//  Created by sonson on 09/03/03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CountryInfo : NSObject {
#if TARGET_OS_IPHONE | TARGET_IPHONE_SIMULATOR
	UIImage		*flagImage;
	UIColor		*color;
#else
	NSImage		*flagImage;
	NSColor		*color;
#endif
	NSString	*name;
	NSString	*countryCode;
}
#if TARGET_OS_IPHONE | TARGET_IPHONE_SIMULATOR
@property (nonatomic, retain) UIImage *flagImage;
@property (nonatomic, retain) UIColor *color;
#else
@property (nonatomic, retain) NSImage *flagImage;
@property (nonatomic, retain) NSColor *color;
#endif
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *countryCode;
+ (NSMutableArray*)availableCountryCodes;
+ (NSMutableDictionary*)flagDictionary;
+ (void)refreshCountryColors;
+ (CountryInfo*)otherCountries;

+ (NSDictionary*)sharedCountryInfoDictionary;
+ (NSDictionary*)sharedCountryInfoDictionaryWithRevoling;
@end

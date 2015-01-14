//
//  Application.h
//  StoreSales
//
//  Created by sonson on 09/02/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplicationInfo : NSObject {
#if TARGET_OS_IPHONE | TARGET_IPHONE_SIMULATOR
	UIImage		*icon;
	UIColor		*color;
#else
	NSImage		*icon;
	NSColor		*color;
#endif
	NSString	*name;
	NSString	*appleIdentifierString;
	NSString	*parentIdentifierString;
	int			appleIdentifier;
}
#if TARGET_OS_IPHONE | TARGET_IPHONE_SIMULATOR
@property (nonatomic, retain) UIImage *icon;
@property (nonatomic, retain) UIColor *color;
#else
@property (nonatomic, retain) NSImage *icon;
@property (nonatomic, retain) NSColor *color;
#endif
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *appleIdentifierString;
@property (nonatomic, retain) NSString *parentIdentifierString;
@property (nonatomic, assign) int appleIdentifier;
+ (ApplicationInfo*)unknownApplicationInfo;
+ (NSMutableDictionary*)applicationInfoADict;
+ (NSMutableArray*)applicationInfoArray;
+ (void)refreshApplicationColors;
+ (void)updateDummyIcon;

+ (NSDictionary*)sharedApplicationInfoDictionary;
+ (NSDictionary*)sharedApplicationInfoDictionaryWithRevoling;
@end

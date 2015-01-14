//
//  StoreSalesAppDelegate.h
//  StoreSales
//
//  Created by sonson on 09/02/19.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KeychainWrapper.h"

@class ApplicationInfo;
@class SNHUDActivityView;
@class KeychainWrapper;

@interface StoreSalesAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow				*window;
	UITabBarController		*tabBarController;
	NSMutableArray			*applicationInfoArray;
	NSMutableDictionary		*applicationInfoDict;
	float					userCurrencyRate;
	NSString				*currencyDescription;
	NSMutableDictionary		*countryInfoDict;
	
	NSNumberFormatter		*salesFormatter;
	NSNumberFormatter		*unitsFormatter;
	CellOrderType			currentOrderType;
	SNHUDActivityView		*hud;
	KeychainWrapper			*keychainWrapper;
}
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) NSMutableArray *applicationInfoArray;
@property (nonatomic, retain) NSMutableDictionary *applicationInfoDict;
@property (nonatomic, assign) float userCurrencyRate;
@property (nonatomic, assign) CellOrderType currentOrderType;
@property (nonatomic, retain) NSString *currencyDescription;
@property (nonatomic, retain) NSMutableDictionary *countryInfoDict;

@property (nonatomic, retain) NSNumberFormatter *salesFormatter;
@property (nonatomic, retain) NSNumberFormatter *unitsFormatter;

@property (nonatomic, retain) KeychainWrapper *keychainWrapper;
#pragma mark ApplicationInfo reloading
- (void)reloadApplicationInfo;
- (ApplicationInfo*)applicationInfoWithAppleIdentifier:(NSString*)appleIdentifier;
- (void)reloadAllData;
- (void)deleteAllCachePlist;
@end


//
//  StoreSalesAppDelegate.m
//  StoreSales
//
//  Created by sonson on 09/02/19.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "StoreSalesAppDelegate.h"
#import "MainTabBarController.h"
#import "ApplicationInfo.h"
#import "YAHCurrencyTool.h"
#import "CountryInfo.h"
#import "SNHUDActivityView.h"
#import "SNAlertView.h"
#import "SQLiteDBController.h"
#import "UIViewController+TabBarItem.h"

#import <Security/Security.h>

@implementation StoreSalesAppDelegate

@synthesize window = window;
@synthesize tabBarController = tabBarController;
@synthesize applicationInfoArray = applicationInfoArray;
@synthesize applicationInfoDict = applicationInfoDict;
@synthesize userCurrencyRate;
@synthesize currencyDescription;
@synthesize countryInfoDict;
@synthesize currentOrderType;

@synthesize salesFormatter;
@synthesize unitsFormatter;

@synthesize keychainWrapper;

#pragma mark -
#pragma mark Currency

- (void)setupInitialCurrency {
	DNSLogMethod
	
	NSString* currencyCode = [[NSUserDefaults standardUserDefaults] stringForKey:@"currencyCode"];
	
	// for debug
	NSLocale *locale = [NSLocale currentLocale];
	DNSLog(@"UsersDefault's currency code = %@", currencyCode);
	DNSLog(@"Currenct currency code = %@", [locale objectForKey:NSLocaleCurrencyCode]);
	
	if (![currencyCode length]) {
		// have to setup default currency code
		[[NSUserDefaults standardUserDefaults] setObject:[locale objectForKey:NSLocaleCurrencyCode] forKey:@"currencyCode"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	DNSLog(@"UsersDefault's currency code = %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"currencyCode"]);
}

- (void)reloadCurrency {
	DNSLogMethod	
	NSString* currencyCode = [[NSUserDefaults standardUserDefaults] stringForKey:@"currencyCode"];

	DNSLog(@"UsersDefault's currency code = %@", currencyCode);
				 
	self.userCurrencyRate = [YAHCurrencyTool currencyRate:currencyCode targetDatabase:[SQLiteDBController sharedInstance].database];
	
	[[NSUserDefaults standardUserDefaults] synchronize];

	self.currencyDescription = [YAHCurrencyTool baseCurrencyDescription:currencyCode];
	
	DNSLog(@"userCurrencyRate = %f", userCurrencyRate);
	
	// setup number formatter, such as ￥10,000
	self.salesFormatter = [[[NSNumberFormatter alloc] init] autorelease]; 
	[self.salesFormatter setCurrencySymbol:self.currencyDescription];
	[self.salesFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	
	self.unitsFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	[self.unitsFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
}

#pragma mark -
#pragma mark ApplicationInfo reloading

- (void)reloadApplicationInfo {
	self.applicationInfoArray = [ApplicationInfo applicationInfoArray];
	self.applicationInfoDict = [ApplicationInfo applicationInfoADict];
	[ApplicationInfo refreshApplicationColors];
}

- (ApplicationInfo*)applicationInfoWithAppleIdentifier:(NSString*)appleIdentifier {
	ApplicationInfo *info = [self.applicationInfoDict objectForKey:appleIdentifier];
	if (info == nil) {
		info = [ApplicationInfo unknownApplicationInfo];
		info.name = appleIdentifier;
		info.appleIdentifier = [appleIdentifier intValue];
		[UIAppDelegate.applicationInfoDict setObject:info forKey:appleIdentifier];
		[ApplicationInfo refreshApplicationColors];
	}
	return info;
}

- (void)reloadAllData {
	DNSLogMethod
	
	DNSLog(@"UsersDefault's currency code = %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"currencyCode"]);
	
	// setup ApplicationInfo
	[self reloadApplicationInfo];
	[self reloadCurrency];
	
	// setup flag
	self.countryInfoDict = [CountryInfo flagDictionary];
	[CountryInfo refreshCountryColors];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
	}
	else if (buttonIndex == 1) {
		[tabBarController.selectedViewController openSyncWithTutorial];
	}
}

#pragma mark -
#pragma mark Instance method

- (void)openMessageForInAppPurchase {
	BOOL isNotFirstUse = [[NSUserDefaults standardUserDefaults] boolForKey:@"isNotFirstUse"];
	if (!isNotFirstUse) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isNotFirstUseVersion1.1"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	else if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isNotFirstUseVersion1.1"]) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isNotFirstUseVersion1.1"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		// show message, please clear old data in order to rebuild database for In App Purchase.
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"StoreSales", nil)
														message:NSLocalizedString(@"To check \"In App Purchase\", please clear this iPhone's database using info view and send all sales info to this iPhone again.", nil)
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
		[alert show];
		[alert release];
	}
}

- (void)openTutorialConfirmation {
	DNSLogMethod
	BOOL isNotFirstUse = [[NSUserDefaults standardUserDefaults] boolForKey:@"isNotFirstUse"];
	if (!isNotFirstUse) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"StoreSales", nil)
														message:NSLocalizedString(@"To use StoreSaels, you have to pair iPhone with Mac over WiFi network. Would you like to read the tutorial about setup? Of course, you can read it via sync view later.", nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"No thanks.", nil)
											  otherButtonTitles:NSLocalizedString(@"Sure", nil), nil];
		[alert show];
		[alert release];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isNotFirstUse"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void)deleteAllCachePlist {
	DNSLogMethod
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *cacheDirecotyPath = [NSString stringWithFormat:@"%@/cache/", documentsDirectory];
	
	NSArray *filenames = [[NSFileManager defaultManager] subpathsAtPath:cacheDirecotyPath];
	for (NSString *filename in filenames) {
		NSError *error = nil;
		NSString *path = [cacheDirecotyPath stringByAppendingPathComponent:filename];
		[[NSFileManager defaultManager] removeItemAtPath:path error:&error];
		if (error) {
			DNSLog(@"%@", [error localizedDescription]);
		}
		else {
			DNSLog(@"Delete %@", path);
		}
	}
}

- (void)deleteSalesCachePlist {
	DNSLogMethod
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *cacheDirecotyPath = [NSString stringWithFormat:@"%@/cache/", documentsDirectory];
	
	NSArray *filenames = [[NSFileManager defaultManager] subpathsAtPath:cacheDirecotyPath];
	for (NSString *filename in filenames) {
		if ([filename rangeOfString:@"Sales"].location != NSNotFound) {
			NSError *error = nil;
			NSString *path = [cacheDirecotyPath stringByAppendingPathComponent:filename];
			[[NSFileManager defaultManager] removeItemAtPath:path error:&error];
			if (error) {
				DNSLog(@"%@", [error localizedDescription]);
			}
			else {
				DNSLog(@"Delete %@", path);
			}
		}
	}
}

#pragma mark -
#pragma mark Override

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// setup default currency code
	[self setupInitialCurrency];
	
	// set application delegate
	UIAppDelegate = self;
	CGContextCheckShadowDirection();
	
	// delete cache
	NSString* currenctCurrencyCode = [[NSUserDefaults standardUserDefaults] stringForKey:@"currencyCode"];
	NSString* previousCurrencyCode = [[NSUserDefaults standardUserDefaults] stringForKey:@"previousCurrencyCode"];
	if (![currenctCurrencyCode isEqualToString:previousCurrencyCode]) {
		// cache is deleted if currency code has been shanged.
		DNSLog(@"cache is deleted if currency code has been shanged.");
		[UIAppDelegate deleteSalesCachePlist];
	}
	
	// setup keychain class
    KeychainWrapper *wrapper= [[KeychainWrapper alloc] init];
    self.keychainWrapper = wrapper;
    [wrapper release];
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// initialize valiables
	self.currentOrderType = CellOrderUnits;
	[self reloadAllData];
	
	// Setup Tabbar
	self.tabBarController = [[MainTabBarController alloc] initWithNibName:nil bundle:nil];
	[tabBarController setViewControllers:[MainTabBarController defaultNavigationControllers]];
		
	// Override point for customization after app launch    
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
	window.backgroundColor = [UIColor blackColor];
	
	// Setup HUD
	hud = [[SNHUDActivityView alloc] init];
	
	// message when running
	// let users open tutorial or tell users to rebuild database in order to enable In App Purchase.
	[self openMessageForInAppPurchase];
	[self openTutorialConfirmation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// save currenct currency
	NSString* currenctCurrencyCode = [[NSUserDefaults standardUserDefaults] stringForKey:@"currencyCode"];
	[[NSUserDefaults standardUserDefaults] setObject:currenctCurrencyCode forKey:@"previousCurrencyCode"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark Method for HUD

- (void)openHUDOfString:(NSString*)message {
	if(hud.superview == nil) {
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
		[message retain];	// add retain count, for another thread.
		[NSThread detachNewThreadSelector:@selector(openActivityHUDOfString:) toTarget:self withObject:message];
	}
}

- (void)openActivityHUDOfString:(id)obj {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@synchronized(self) {
		[hud setupWithMessage:(NSString*)obj];
		[obj release];
		[hud arrange:window.frame];
		[window addSubview:hud];
	}
	[pool release];
	[NSThread exit];
}

- (void)closeHUD {
	if( hud.superview != nil ) {
		while( [[UIApplication sharedApplication] isIgnoringInteractionEvents] ) {
			DNSLog( @"try to cancel ignoring interaction" );
			[NSThread sleepForTimeInterval:0.05];
			[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		}
		[hud dismiss];
	}
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	// dummy
	NSLocalizedString(@"Please retry to reload info later.", nil);
	
	[keychainWrapper release];
	[salesFormatter release];
	[unitsFormatter release];	
	[applicationInfoArray release];
    [window release];
	[tabBarController release];
	[currencyDescription release];
	[hud release];
    [super dealloc];
}


@end

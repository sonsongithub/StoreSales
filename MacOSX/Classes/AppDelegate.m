#import "AppDelegate.h"
#import "BonjourController.h"
#import "FileSendWindowController.h"
#import "PreferencesWindowController.h"
#import "ITCLogParser.h"

#import "ITCDownloadController.h"

#import "SQLiteDBController.h"

#import "SNDownloadManager.h"

#import "ITCDownloader.h"

// Main controllers
#import "FileSendController.h"
#import "BonjourController.h"
#import "ITCDownloadController.h"
#import "NSBundle+2tch.h"
#import "FirstConfirmWindowController.h"
#import "MainMenuController.h"
#import "ITCSQLiteInserter.h"
#import "LicenseViewController.h"

// for test
#import "MainWindowController.h"

// Automatic downloader
#import "ITCDownloadScheduler.h"

@implementation AppDelegate

@synthesize fileSendController, bonjourController, itcDownloadController, mainMenuController;

- (void)allDownloadTaskCompleted:(NSNotification*)notification {
	DNSLogMethod
	//
	// Update all application and country flag data
	//
	[fileSendController restartBonjourServer];
}

#pragma mark -
#pragma mark Setup basic settings

- (id)infoValueForKey:(NSString*)key {
	// to get application's bundle name
	if ([[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:key])
		return [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:key];
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:key];
}

- (void)setupDefaultLogFilePathSetting {
	DNSLogMethod
	// initialize default path where log files are saved into.
	NSString *logFileFolderPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"logFileFolderPath"];
	if (!logFileFolderPath) {
		// make path 
		NSArray *array = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,NSUserDomainMask,YES);
		NSString *NSApplicationSupportDirectoryPath = [array objectAtIndex:0];
		NSString *name = [self infoValueForKey:@"CFBundleName"];
		NSString *path = [NSApplicationSupportDirectoryPath stringByAppendingPathComponent:name];
		
		// make default path into home/libaray/application support/<Application name>/
//		[[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];
		[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
		
		// make default path into home/libaray/application support/<Application name>/log
		path = [path stringByAppendingPathComponent:@"log"];
//		[[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];
		[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
		
		// save path info into userdefaults
		[[NSUserDefaults standardUserDefaults] setObject:path forKey:@"logFileFolderPath"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

#pragma mark -
#pragma mark device infomation mangement

- (void)removePairedDeviceSetting {
	//
	// Remove sending log which is related to current device
	//
	char *delete_from_sendLog_table = "delete from sendLog;";
	sqlite3 *database = [SQLiteDBController sharedInstance].database;
	sqlite3_exec( database, delete_from_sendLog_table, NULL, NULL, NULL );
	
	//
	// remove all info abount the paired device from userdefaults
	//
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"iphone"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"udid"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"passcode"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updatePairedDeviceWithName:(NSString*)name UDID:(NSString*)udid passcode:(NSString*)passcode {
	//
	// Remove sending log which is related to current device
	//
	char *delete_from_sendLog_table = "delete from sendLog;";
	sqlite3 *database = [SQLiteDBController sharedInstance].database;
	sqlite3_exec( database, delete_from_sendLog_table, NULL, NULL, NULL );

	//
	// set all info abount the paired device into userdefaults
	//
	[[NSUserDefaults standardUserDefaults] setObject:name forKey:@"iphone"];
	[[NSUserDefaults standardUserDefaults] setObject:udid forKey:@"udid"];
	[[NSUserDefaults standardUserDefaults] setObject:passcode forKey:@"passcode"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark Action when selecting menu item.

- (void)openPreferences:(id)sender {
	DNSLogMethod
	PreferencesWindowController *con = [PreferencesWindowController sharedWindowController];
	[con showWindow:nil];
	[[con window] center];
	[[con window] orderFront:nil];
	[NSApp activateIgnoringOtherApps:YES];
	
	// Disabled barmenu while some task is done.
	[UIAppDelegate.mainMenuController setEnabled:NO];
}

- (void)download:(id)sender {
	DNSLogMethod
	[fileSendController pauseBonjourServer];
	
	[UIAppDelegate.mainMenuController startAnimation];
	
	[UIAppDelegate.mainMenuController setEnabled:NO];
	[[ITCDownloader sharedManager] downloadReports];
	
}

- (void)selectQuitItem:(id)sender {
	DNSLogMethod
	[NSApp terminate:self]; 
}

- (void)chooseLogFileFolder:(id)sender {
	DNSLogMethod
	[NSApp activateIgnoringOtherApps:YES];
	NSOpenPanel	*panel = [[NSOpenPanel openPanel] retain];
	[panel setCanChooseFiles:NO];
	[panel setCanChooseDirectories:YES];
	[panel setResolvesAliases:YES];
	[panel setAllowsMultipleSelection:NO];
	
	NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"logFileFolderPath"];
	[panel beginForDirectory:path file:nil types:nil modelessDelegate:self didEndSelector:@selector(didEndChooseFolderSheet:returnCode:contextInfo:) contextInfo:nil];

	// Disabled barmenu while some task is done.
	[UIAppDelegate.mainMenuController setEnabled:NO];
}

- (void)openLogFileFolder:(id)sender {
	DNSLogMethod
	NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"logFileFolderPath"];
	[[NSWorkspace sharedWorkspace] openFile:path];
}

- (void)selectPairingItem:(id)sender {
	DNSLogMethod
	[NSApp activateIgnoringOtherApps:YES];
	[bonjourController showWindow:nil];
	[[bonjourController window] center];
	[[bonjourController window] orderFront:nil];
	[fileSendController pauseBonjourServer];
	
	// Disabled barmenu while some task is done.
	[UIAppDelegate.mainMenuController setEnabled:NO];
}

- (void)selectHelpItem:(id)sender {
	DNSLogMethod
	NSURL *URL = [NSURL URLWithString:NSLocalizedString(@"supportURL", nil)];
	[[NSWorkspace sharedWorkspace] openURL:URL];
}

- (void)selectVersionItem:(id)sender {
	DNSLogMethod
	[NSApp activateIgnoringOtherApps:YES];

#ifdef _DEBUG
	NSString *versionString = [NSString stringWithFormat:@"b%@ r%@ Debug", [NSBundle infoValueFromMainBundleForKey:@"CFBundleVersion"], [NSBundle infoValueFromMainBundleForKey:@"CFBundleSubversionRevision"]];
#else
	NSString *versionString = [NSString stringWithFormat:@"b%@ r%@", [NSBundle infoValueFromMainBundleForKey:@"CFBundleVersion"], [NSBundle infoValueFromMainBundleForKey:@"CFBundleSubversionRevision"]];
#endif
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
			   versionString, @"Version",
			   nil];
	[[NSApplication sharedApplication] orderFrontStandardAboutPanelWithOptions:options];
}

- (void)selectOpenLogViewItem:(id)sender {
	DNSLogMethod
	[NSApp activateIgnoringOtherApps:YES];
	[[MainWindowController sharedInstance] showWindow:nil];
	
	// Disabled barmenu while some task is done.
	[UIAppDelegate.mainMenuController setEnabled:NO];
}

- (void)openLicense:(id)sender {
	DNSLogMethod
	LicenseViewController *con = [[LicenseViewController alloc] init];
	[con showWindow:nil];
	[[con window] center];
	[[con window] orderFront:nil];
	[NSApp activateIgnoringOtherApps:YES];
	
	// Disabled barmenu while some task is done.
	[UIAppDelegate.mainMenuController setEnabled:NO];
}

#pragma mark -
#pragma mark Delegate for NSOpenPanel

- (void)didEndChooseFolderSheet:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	DNSLogMethod
	if (returnCode == NSOKButton) {
		NSString *folderPath = [sheet directory];
		[[NSUserDefaults standardUserDefaults] setObject:folderPath forKey:@"logFileFolderPath"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[mainMenuController reloadMenuItemAboutPairedDevice];
	}
	[sheet autorelease];
	
	// Enabled barmenu after closing choose folder sheet
	[UIAppDelegate.mainMenuController setEnabled:YES];
}

#pragma mark -
#pragma mark Override

- (void)applicationDidFinishLaunching:(NSNotification*)aNote {
	DNSLogMethod
	UIAppDelegate = self;
	
	FirstConfirmWindowController *con = [FirstConfirmWindowController defaultController];
	[con show];
	
	fileSendController = [[FileSendController alloc] init];
	bonjourController = [[BonjourController defaultController] retain];
	itcDownloadController = [[ITCDownloadController alloc] init];
#ifdef _ITC_SCRAPING	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allDownloadTaskCompleted:) name:kSNDownloadTaskCompleted object:[SNDownloadManager sharedInstance]];
#else
	NSMenuItem *item = nil;
	item = [barMenu itemWithTag:8];		// Preference
	[barMenu removeItem:item];
	item = [barMenu itemWithTag:9];		// Download
	[barMenu removeItem:item];
	item = [barMenu itemWithTag:10];	// delimeter bar
	[barMenu removeItem:item];
#endif
	[self setupDefaultLogFilePathSetting];
	[mainMenuController initializeMenuItems];
	
	[ITCSQLiteInserter insertDownloadedAllFiles];
//	[ITCSQLiteInserter updateAppInfoAndCurrencyRate];
	
	// for test
	// [[MainWindowController sharedInstance] showWindow:nil];
	
	[[ITCDownloadScheduler sharedInstance] validate];
}

@end

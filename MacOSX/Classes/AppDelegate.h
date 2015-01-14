#import <Cocoa/Cocoa.h>

// Growl
#import "FileSendController.h"

@class FileSendController;
@class BonjourController;
@class ITCDownloadController;
@class MainMenuController;

#define ICON_UPDATE_ANIMATION_INTERVAL 0.1

@interface AppDelegate : NSObject {
    IBOutlet NSMenu				*barMenu;
	IBOutlet MainMenuController	*mainMenuController;
	
	BonjourController			*bonjourController;
	FileSendController			*fileSendController;
	ITCDownloadController		*itcDownloadController;
}
@property (nonatomic, readonly) FileSendController* fileSendController;
@property (nonatomic, readonly) BonjourController* bonjourController;
@property (nonatomic, readonly) ITCDownloadController* itcDownloadController;
@property (nonatomic, readonly) MainMenuController* mainMenuController;

#pragma mark notification
- (void)allDownloadTaskCompleted:(NSNotification*)notification;

#pragma mark -
#pragma mark Setup basic settings
- (id)infoValueForKey:(NSString*)key;
- (void)setupDefaultLogFilePathSetting;

#pragma mark -
#pragma mark device infomation mangement
- (void)removePairedDeviceSetting;
- (void)updatePairedDeviceWithName:(NSString*)name UDID:(NSString*)udid passcode:(NSString*)passcode;

#pragma mark -
#pragma mark Action when selecting menu item.
- (void)openPreferences:(id)sender;
- (void)download:(id)sender;
- (void)selectQuitItem:(id)sender;
- (void)chooseLogFileFolder:(id)sender;
- (void)openLogFileFolder:(id)sender;
- (void)selectPairingItem:(id)sender;
- (void)selectHelpItem:(id)sender;
- (void)selectVersionItem:(id)sender;

@end

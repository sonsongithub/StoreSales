//
//  MainMenuController.h
//  StoreSales
//
//  Created by sonson on 09/06/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	MenuBarSync			= 0,
	MenuBarPairing		= 1,
	MenuBarDeviceName	= 4,
	MenuBarDeviceStatus = 2,
	MenuBarQuit			= 3,
	MenuBarPath			= 5,
	MenuBarChoosePath	= 7,
	MenuBarPromptPath	= 6,
	MenuBarPreferences	= 8,
	MenuBarDownload		= 9,
	MenuBarHelp			= 11,
	MenuBarVersion		= 12,
	MenuBarContentView	= 13,
	MenuBarSparkleCheck	= 14,
	MenuBarLicense		= 15,
}MenuBarTag;

@interface MainMenuController : NSObject {
	NSStatusItem				*rootItem;
    IBOutlet NSMenu				*barMenu;
	
	NSThread					*iconAnimationThread;
	
	id							delegate;
	
	NSArray						*loadAnimationFrames;
}
@property (nonatomic, retain) NSThread* iconAnimationThread;

#pragma mark -
#pragma mark Instance method
- (void)setEnabledMenuItems:(BOOL)enabled;
- (void)obtainRootMenuItem;
- (void)setEnabled:(BOOL)enabled;

#pragma mark -
#pragma mark Animation management of system menu bar icon
- (void)startAnimation;
- (void)stopAnimation;
- (void)startMenuIconAnimation:(id)info;
- (void)updateLogFolderPathMenuItem;
- (void)reloadMenuItemAboutPairedDevice;
- (void)initializeMenuItems;

@end

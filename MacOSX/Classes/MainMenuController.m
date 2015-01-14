//
//  MainMenuController.m
//  StoreSales
//
//  Created by sonson on 09/06/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MainMenuController.h"
#import "ITCDownloadScheduler.h"

@implementation MainMenuController

@synthesize iconAnimationThread;

#pragma mark -
#pragma mark Instance method

- (void)setEnabled:(BOOL)enabled {
	[rootItem setEnabled:enabled];
	if (enabled) {
		[rootItem setImage:[NSImage imageNamed:@"menuIcon.png"]];
		[[ITCDownloadScheduler sharedInstance] validate];
	}
	else {
		[rootItem setImage:[NSImage imageNamed:@"menuIconDisabled.png"]];
		[[ITCDownloadScheduler sharedInstance] invalidate];
	}
}

- (void)setEnabledMenuItems:(BOOL)enabled {
	NSMenuItem *anItem = nil;
	if (enabled) {
		anItem = [barMenu itemWithTag:MenuBarPairing];
		[anItem setAction:@selector(selectPairingItem:)];
		[anItem setTarget:delegate];
		
		anItem = [barMenu itemWithTag:MenuBarChoosePath];
		[anItem setAction:@selector(chooseLogFileFolder:)];
		[anItem setTarget:delegate];
		[anItem setTitle:NSLocalizedString(@"Choose Log File Folder", nil)];
		
		anItem = [barMenu itemWithTag:MenuBarPromptPath];
		[anItem setAction:@selector(openLogFileFolder:)];
		[anItem setTarget:delegate];
		
		anItem = [barMenu itemWithTag:MenuBarHelp];
		[anItem setTitle:NSLocalizedString(@"Help", nil)];
		[anItem setAction:@selector(selectHelpItem:)];
		[anItem setTarget:delegate];
		
		anItem = [barMenu itemWithTag:MenuBarVersion];
		[anItem setTitle:NSLocalizedString(@"About StoreSales", nil)];
		[anItem setAction:@selector(selectVersionItem:)];
		[anItem setTarget:delegate];
		
		anItem = [barMenu itemWithTag:MenuBarSparkleCheck];
		[anItem setTitle:NSLocalizedString(@"Check for Updates...", nil)];
		
		anItem = [barMenu itemWithTag:MenuBarLicense];
		[anItem setTitle:NSLocalizedString(@"About License", nil)];
		[anItem setAction:@selector(openLicense:)];
		[anItem setTarget:delegate];
		
//		ContentView
//		anItem = [barMenu itemWithTag:MenuBarContentView];
//		[anItem setTitle:NSLocalizedString(@"Open Log View", nil)];
//		[anItem setAction:@selector(selectOpenLogViewItem:)];
//		[anItem setTarget:delegate];
		
#ifdef _ITC_SCRAPING		
		anItem = [barMenu itemWithTag:MenuBarPreferences];
		[anItem setTitle:NSLocalizedString(@"Preferences...", nil)];
		[anItem setAction:@selector(openPreferences:)];
		[anItem setTarget:delegate];
		
		anItem = [barMenu itemWithTag:MenuBarDownload];
		[anItem setTitle:NSLocalizedString(@"Download Sales Log", nil)];
		[anItem setAction:@selector(download:)];
		[anItem setTarget:delegate];
#endif
	}
	else {
		anItem = [barMenu itemWithTag:MenuBarPairing];
		[anItem setAction:nil];
		
		anItem = [barMenu itemWithTag:MenuBarChoosePath];
		[anItem setAction:nil];
		
		anItem = [barMenu itemWithTag:MenuBarPromptPath];
		[anItem setAction:nil];
		
		anItem = [barMenu itemWithTag:MenuBarHelp];
		[anItem setAction:nil];
		
		anItem = [barMenu itemWithTag:MenuBarVersion];
		[anItem setAction:nil];

//		ContentView
//		anItem = [barMenu itemWithTag:MenuBarContentView];
//		[anItem setAction:nil];
		
#ifdef _ITC_SCRAPING		
		anItem = [barMenu itemWithTag:MenuBarPreferences];
		[anItem setAction:nil];
		
		anItem = [barMenu itemWithTag:MenuBarDownload];
		[anItem setAction:nil];
#endif
	}
}

- (void)obtainRootMenuItem {
	DNSLogMethod
	NSStatusBar *bar = [NSStatusBar systemStatusBar];
	NSStatusItem *sbItem = [bar statusItemWithLength:NSVariableStatusItemLength];
	[sbItem setImage:[NSImage imageNamed:@"menuIcon.png"]];
	[sbItem setAlternateImage:[NSImage imageNamed:@"menuIconSelected.png"]];
	[sbItem setHighlightMode:YES];
	rootItem = [sbItem retain];
}

#pragma mark -
#pragma mark Animation management of system menu bar icon

- (void)startAnimation {
	DNSLogMethod
	// stop last animation
	[self stopAnimation];
	
	// make new thread
	self.iconAnimationThread = [[NSThread alloc] initWithTarget:self selector:@selector(startMenuIconAnimation:) object:nil];
	[iconAnimationThread release];
	[self.iconAnimationThread start];
}

- (void)stopAnimation {
	DNSLogMethod
	// try to cancel a current running thread.
	[iconAnimationThread cancel];
	while (iconAnimationThread && ![iconAnimationThread isFinished]) {
		// wait
		[NSThread sleepForTimeInterval:0.1];
	}
}

- (void)startMenuIconAnimation:(id)info {
	// start animating
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	int frame = 0;	
    while (1) {
		if ([iconAnimationThread isCancelled]) {
			break;
		}
		
		// Update menu icon
		@synchronized(self) {
			if (frame < 8) {
				[rootItem setImage:[loadAnimationFrames objectAtIndex:frame]];
			}
		}
		
		// increment frame number
		// back to first frame when reaching final frame.
		frame++;
		if (frame > 7) {
			frame = 0;
		}
		
		// sleep
		[NSThread sleepForTimeInterval:ICON_UPDATE_ANIMATION_INTERVAL];
    }
	
	// set normal icon.
	[rootItem setImage:[NSImage imageNamed:@"menuIcon.png"]];
	
    [pool release];
	DNSLog(@"Exit - animation thread");
	[NSThread exit];
}

- (void)updateLogFolderPathMenuItem {
	// update menu item's title with log folder's path.
	NSMenuItem*anItem = [barMenu itemWithTag:MenuBarPromptPath];
	NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"logFileFolderPath"];
	[anItem setTitle:path];
}

- (void)reloadMenuItemAboutPairedDevice {
	// reload menu item after updating info. about the paired device.
	NSMenuItem *anItem = nil;
	NSString *iphone = [[NSUserDefaults standardUserDefaults] objectForKey:@"iphone"];
	NSString *udid = [[NSUserDefaults standardUserDefaults] objectForKey:@"udid"];
	NSString *passcode = [[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"];
	
	if (!iphone || !udid || !passcode) {
		// all info filed out
//		[self removePairedDeviceSetting];
		
		anItem = [barMenu itemWithTag:MenuBarSync];
		[anItem setTitle:NSLocalizedString(@"No device", nil)];
		[anItem setAction:nil];
		
		anItem = [barMenu itemWithTag:MenuBarPairing];
		[anItem setTitle:NSLocalizedString(@"Pairing with new device", nil)];
		
		anItem = [barMenu itemWithTag:MenuBarDeviceName];
		[anItem setTitle:NSLocalizedString(@"No device", nil)];
		
		anItem = [barMenu itemWithTag:MenuBarDeviceStatus];
		[anItem setTitle:NSLocalizedString(@"Pairing device", nil)];
	}
	else {
		// all info are not filled out
		anItem = [barMenu itemWithTag:MenuBarSync];
		NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Sync with %@", nil), iphone];
		[anItem setTitle:title];
		[anItem setAction:@selector(selectSyncItem:)];
		
		anItem = [barMenu itemWithTag:MenuBarPairing];
		[anItem setTitle:NSLocalizedString(@"Revoke pairing setting", nil)];
		
		anItem = [barMenu itemWithTag:MenuBarDeviceName];
		[anItem setTitle:iphone];
		
		anItem = [barMenu itemWithTag:MenuBarDeviceStatus];
		[anItem setTitle:NSLocalizedString(@"Pairing device", nil)];
		
	}
	
	anItem = [barMenu itemWithTag:6];
	NSString *logpath = [[NSUserDefaults standardUserDefaults] objectForKey:@"logFileFolderPath"];
	if ([logpath length])
		[anItem setTitle:logpath];
}

- (void)initializeMenuItems {
	// setup all menu items
	[rootItem setMenu:barMenu];
	
	NSMenuItem *anItem = nil;
	anItem = [barMenu itemWithTag:MenuBarQuit];
	[anItem setTitle:NSLocalizedString(@"Quit", nil)];
	[anItem setAction:@selector(selectQuitItem:)];
	[anItem setTarget:delegate];
	
	anItem = [barMenu itemWithTag:MenuBarHelp];
	[anItem setTitle:NSLocalizedString(@"Help", nil)];
	[anItem setAction:@selector(selectHelpItem:)];
	[anItem setTarget:delegate];
	
	anItem = [barMenu itemWithTag:MenuBarVersion];
	[anItem setTitle:NSLocalizedString(@"About StoreSales", nil)];
	[anItem setAction:@selector(selectVersionItem:)];
	[anItem setTarget:delegate];
	
	anItem = [barMenu itemWithTag:MenuBarSync];
	[anItem setTarget:delegate];
	
	anItem = [barMenu itemWithTag:MenuBarPath];
	[anItem setTitle:NSLocalizedString(@"Log File Folder", nil)];
	
	[self setEnabledMenuItems:YES];
	
	loadAnimationFrames = [[NSArray arrayWithObjects:
							[NSImage imageNamed:@"menuIcon01.png"],
							[NSImage imageNamed:@"menuIcon02.png"],
							[NSImage imageNamed:@"menuIcon03.png"],
							[NSImage imageNamed:@"menuIcon04.png"],
							[NSImage imageNamed:@"menuIcon05.png"],
							[NSImage imageNamed:@"menuIcon06.png"],
							[NSImage imageNamed:@"menuIcon07.png"],
							[NSImage imageNamed:@"menuIcon08.png"],
							nil] retain];
	
	[self reloadMenuItemAboutPairedDevice];
}

#pragma mark -
#pragma mark Override

- (void)awakeFromNib {
}

- (id) init {
	DNSLogMethod
	self = [super init];
	if (self != nil) {
		[self obtainRootMenuItem];
	}
	return self;
}

#pragma mark -
#pragma mark dealloc

- (void) dealloc {
	[loadAnimationFrames release];
	[super dealloc];
}


@end

#import "PreferencesWindowController.h"

#import "KeychainAccessor.h"

PreferencesWindowController* sharedPreferencesWindowController = nil;


BOOL WarnWhenRequestingFromButtonState(NSCellStateValue value) {
	DNSLog(@"NSCellStateValue=%d", value);
	if (value == 0) {
		return NO;
	}
	return YES;
}

NSCellStateValue ButtonStateFromWarnWhenRequesting(BOOL value) {
	if (value) {
		return 1;
	}
	return 0;
}

@implementation PreferencesWindowController

#pragma mark -
#pragma mark Instance method

- (void)updateUI {
	//
	// Update UI
	//
	BOOL buttonState = [[NSUserDefaults standardUserDefaults] boolForKey:@"WarnWhenRequesting"];
	[checkBox setState:ButtonStateFromWarnWhenRequesting(buttonState)];
	
	BOOL itcDownloadCheckBoxState = [[NSUserDefaults standardUserDefaults] boolForKey:@"IsActivatedITCDownloadScheduler"];
	[itcDownloadCheckBox setState:ButtonStateFromWarnWhenRequesting(itcDownloadCheckBoxState)];
	
	//
	// Restore user name from NSUserDefault
	//
	NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"iTunesConnectUserName"];
	NSString *password = [KeychainAccessor passwordForService:@"iTunesConnectStoreSales" account:username];
	NSString *vndnumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"iTunesConnectVNDNumber"];
	
	DNSLog(@"%@", username);
	
	if ([username length] > 0) {
		[usernameField setStringValue:username];
	}
	if ([password length] > 0) {
		[passwordField setStringValue:password];
	}
	if ([vndnumber length] > 0) {
		[vndnumberField setStringValue:vndnumber];
	}
	
	// UI Label
//	[checkBox setTitle:NSLocalizedString(@"Dont warn when reqeusting from iPhone.", nil)];
//	[usernameLabel setStringValue:NSLocalizedString(@"Username:", nil)];
//	[passwordLabel setStringValue:NSLocalizedString(@"Password:", nil)];
//	[self.window setTitle:NSLocalizedString(@"Preference", nil)];
}

#pragma mark -
#pragma mark IBAction

- (IBAction)pushCheckBox:(id)sender {   
	DNSLogMethod
}

- (IBAction)showWindow:(id)sender {
	DNSLogMethod
	[self updateUI];
}

- (IBAction)ok:(id)sender {
	DNSLogMethod
	BOOL WarnWhenRequesting = WarnWhenRequestingFromButtonState([checkBox state]);
	[[NSUserDefaults standardUserDefaults] setBool:WarnWhenRequesting forKey:@"WarnWhenRequesting"];
	
	BOOL isActivatedITCDownloadScheduler = WarnWhenRequestingFromButtonState([itcDownloadCheckBox state]);
	[[NSUserDefaults standardUserDefaults] setBool:isActivatedITCDownloadScheduler forKey:@"IsActivatedITCDownloadScheduler"];
	
	//
	// Save iTunes connect account info.
	//
	NSString *username = [usernameField stringValue];
	NSString *password = [passwordField stringValue];
	NSString *vndnumber = [vndnumberField stringValue];
	
	//
	// Save password into Keychain.
	//
	[KeychainAccessor changePasswordForService:@"iTunesConnectStoreSales" account:username password:password];
	
	//
	// Save user name
	//
	[[NSUserDefaults standardUserDefaults] setObject:username forKey:@"iTunesConnectUserName"];
	[[NSUserDefaults standardUserDefaults] setObject:vndnumber forKey:@"iTunesConnectVNDNumber"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self close];
}

- (void)close {
	[super close];
	
	// Enabled barmenu after closing choose folder sheet
	[UIAppDelegate.mainMenuController setEnabled:YES];
}

- (IBAction)cancel:(id)sender {
	DNSLogMethod
	[self close];
}

#pragma mark -
#pragma mark Class method

+ (PreferencesWindowController*)sharedWindowController {
	if (sharedPreferencesWindowController == nil) {
		sharedPreferencesWindowController = [[PreferencesWindowController alloc] init];
	}
	return sharedPreferencesWindowController;
}

#pragma mark -
#pragma mark Override

- (void)windowDidLoad {
	[super windowDidLoad];
	[self updateUI];
}

- (id)init {
	DNSLogMethod
	if ((self = [super initWithWindowNibName:@"PreferencesWindowController"])) {
		DNSLogMethod
	}
	return self;
}

@end

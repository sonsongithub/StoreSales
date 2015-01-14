#import <Cocoa/Cocoa.h>

@interface PreferencesWindowController : NSWindowController {
    IBOutlet NSButton			*checkBox;
    IBOutlet NSButton			*itcDownloadCheckBox;
    IBOutlet NSTextField		*usernameField;
    IBOutlet NSSecureTextField	*passwordField;
    IBOutlet NSTextField		*vndnumberField;
    IBOutlet NSTextField		*passwordLabel;
    IBOutlet NSTextField		*usernameLabel;
    IBOutlet NSTextField		*vndnumberLabel;
}

#pragma mark -
#pragma mark IBAction
- (IBAction)pushCheckBox:(id)sender;
- (IBAction)showWindow:(id)sender;
- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;
#pragma mark -
#pragma mark Class method
+ (PreferencesWindowController*)sharedWindowController;

@end

BOOL WarnWhenRequestingFromButtonState(NSCellStateValue value);
NSCellStateValue ButtonStateFromWarnWhenRequesting(BOOL value);
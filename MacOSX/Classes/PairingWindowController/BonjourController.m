//
//  BonjourController.m
//  StoreSales
//
//  Created by sonson on 09/04/30.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BonjourController.h"
#import "PasscodeInputSheetController.h"
#import "BonjourClient.h"
#import "MainMenuController.h"
#import "FileSendController.h"

@implementation BonjourController

@synthesize client;

#pragma mark -
#pragma mark Class method

+ (BonjourController*)defaultController {
	BonjourController *obj = [[BonjourController alloc] init];
	return [obj autorelease];
}

#pragma mark -
#pragma mark UI

- (void)reloadUIAutomatically {
	NSString *iphone = [[NSUserDefaults standardUserDefaults] objectForKey:@"iphone"];
	NSString *udid = [[NSUserDefaults standardUserDefaults] objectForKey:@"udid"];
	NSString *passcode = [[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"];
	
	if (!iphone || !udid || !passcode) {
		[self reloadUI:YES];
	}
	else {
		[self reloadUI:NO];
	}
}

- (void)reloadUI:(BOOL)paired {
	DNSLogMethod
	if (!paired) {
		[removeButton setHidden:NO];
		NSString *iphone = [[NSUserDefaults standardUserDefaults] objectForKey:@"iphone"];
		NSString *buttonTitle = [NSString stringWithFormat:NSLocalizedString(@"Remove %@'s setting", nil), iphone];
		[removeButton setTitle:buttonTitle];
		[[self window] setTitle:NSLocalizedString(@"Revoke pairing setting", nil)];
	}
	else {
		[[self window] setTitle:NSLocalizedString(@"Pairing with new device", nil)];
		[removeButton setHidden:YES];
	}
}

#pragma mark -
#pragma mark IBAction

- (IBAction)pushRemoveCurrentDevice:(id)sender {
	[UIAppDelegate removePairedDeviceSetting];
	[UIAppDelegate.mainMenuController reloadMenuItemAboutPairedDevice];
	[self reloadUIAutomatically];
	[tableView reloadData];
}

- (void) doubleClicked:(id)sender {
	DNSLogMethod
	if ([client.foundServices count] > 0) {
		client.currentResolvedService = [client.foundServices objectAtIndex:[tableView selectedRow]];
		[self.client tryToResolveNewService:client.currentResolvedService];
	}
	[tableView reloadData];
}

- (void)passcodeInputSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	DNSLogMethod
	[[sheet windowController] autorelease];
	[client stop];
	client.delegate = self;
	[client startServiceBrowser];
	if (returnCode == PasscodeInputOK) {
		[self close];
	}
	[tableView reloadData];
}

#pragma mark -
#pragma mark NSNetServiceBrowserDelegate

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didRemoveService:(NSNetService*)service moreComing:(BOOL)moreComing {	
	DNSLogMethod
	if (!moreComing) {
		[tableView reloadData];
	}
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didFindService:(NSNetService*)service moreComing:(BOOL)moreComing {
	DNSLogMethod
	if (!moreComing) {
		[tableView reloadData];
	}
}

#pragma mark -
#pragma mark NSNetServiceDelegate

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
	DNSLogMethod
	[tableView reloadData];
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
	DNSLogMethod
	[tableView reloadData];
}

#pragma mark -
#pragma mark StreamManagerDelegate

- (void)openCompletedStream:(NSStream*)stream {
	PasscodeInputSheetController *sheet = [[PasscodeInputSheetController alloc] init];
	sheet.client = client;
	client.delegate = sheet;
	sheet.parentWindow = [self window];
	[NSApp beginSheet:[sheet window]
	   modalForWindow:[self window]
		modalDelegate:self
	   didEndSelector:@selector(passcodeInputSheetDidEnd:returnCode:contextInfo:)
		  contextInfo:nil];
}

#pragma mark -
#pragma mark NSTableViewDelegate

- (int)numberOfRowsInTableView:(NSTableView *)theTableView {
	int row = 0;
	for (NSNetService* service in client.foundServices) {
		if ([[service name] length])
			row++;
	}
	return row;
}

- (void)tableView:(NSTableView *)theTableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)theColumn row:(int)rowIndex {
	id	identifier = [theColumn identifier];
	if([identifier isEqualToString:@"switch"]) {
		NSNetService* service = [client.foundServices objectAtIndex:rowIndex];
		DNSLog(@"Clicked - %@ = %d", [service name], [object intValue]);
		NSString *iphone = [[NSUserDefaults standardUserDefaults] objectForKey:@"iphone"];
		if ([[service name] isEqualToString:iphone]) {
			[UIAppDelegate removePairedDeviceSetting];
			[UIAppDelegate.mainMenuController reloadMenuItemAboutPairedDevice];
			[self reloadUIAutomatically];
			[tableView reloadData];
		}
		else {
			if ([client.foundServices count] > 0) {
				client.currentResolvedService = [client.foundServices objectAtIndex:[tableView selectedRow]];
				[self.client tryToResolveNewService:client.currentResolvedService];
			}
			[tableView reloadData];
		}	
	}
}

- (id)tableView:(NSTableView *)theTableView objectValueForTableColumn:(NSTableColumn *)theColumn row:(int)rowIndex {
	DNSLog(@"%@", theColumn);
	if ([[theColumn identifier] isEqualToString:@"name"]) {
		if ([client.foundServices count] > 0) {
			NSNetService* service = [client.foundServices objectAtIndex:rowIndex];
			return [service name];
		}
	}
	if ([[theColumn identifier] isEqualToString:@"switch"]) {
		NSButtonCell *cell = [theColumn dataCellForRow:rowIndex];
		NSString *iphone = [[NSUserDefaults standardUserDefaults] objectForKey:@"iphone"];
		NSNetService* service = [client.foundServices objectAtIndex:rowIndex];
		if ([[service name] isEqualToString:iphone])
			[cell setTitle:NSLocalizedString(@"Remove", nil)];
		else
			[cell setTitle:NSLocalizedString(@"Pairing", nil)];
	}
	return nil;
}

#pragma mark -
#pragma mark Override

- (IBAction)pushCloseButton:(id)sender {
	[client stop];
	[UIAppDelegate.fileSendController restartBonjourServer];
	[[self window] close];
	[UIAppDelegate.mainMenuController setEnabled:YES];
}

- (id) init {
	self = [super initWithWindowNibName:@"BonjourListWindow"];
	if (self) {
		self.client = [[[BonjourClient alloc] init] autorelease];
		self.client.searchType = [NSString stringWithFormat:@"_%@._tcp.", kBonjourIdentifier];
		self.client.delegate = self;
	}
	return self;
}

- (void) awakeFromNib {
	DNSLogMethod
	[tableView setHeaderView:nil];
	[removeButton setTitle:NSLocalizedString(@"Remove current device", nil)];
	[self reloadUIAutomatically];
}

- (void)showWindow:(id)sender {
	DNSLogMethod
	[tableView reloadData];
	[self reloadUIAutomatically];
	[client startServiceBrowser];
	[super showWindow:sender];
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	DNSLogMethod
	[client release];
	[super dealloc];
}

@end

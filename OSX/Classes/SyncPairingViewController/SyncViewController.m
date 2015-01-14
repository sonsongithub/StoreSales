//
//  SyncViewController.m
//  StoreSalesClient
//
//  Created by sonson on 09/05/06.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SyncViewController.h"
#import "PairingViewController.h"
#import "BonjourClient.h"
#import "SyncingController.h"
#import "SNDownloadManager.h"
#import "SNDownloadQueue.h"
#import "ITSReviewDownloadQueue.h"
#import "YAHCurrecyCSVDownloadQueue.h"

#import "SQLiteDBController.h"
#import "SNDownloadManager.h"
#import "YAHCurrecyCSVDownloadQueue.h"
#import "ITSTool.h"
#import "ITSReviewDownloadQueue.h"

#import "SNActionSheetController.h"
#import "SNAlertViewAccountInput.h"

#import "SyncProgressSheet.h"
#import "TutorialPageController.h"

@implementation SyncViewController

@synthesize myTableView, client, pairedService, syncController;

+ (UINavigationController*)defaultController {
	SyncViewController *con = [[SyncViewController alloc] init];
	UINavigationController* naviCon = [[UINavigationController alloc] initWithRootViewController:con];
	[con release];
	return [naviCon autorelease];
}

- (void)pushClose:(id)sender {
	[client stop];
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)pushUpdate:(id)sender {
}

- (void)pushHelp:(id)sender {
	TutorialPageController *con = [[[TutorialPageController alloc] init] autorelease];
	UINavigationController *navi = [[[UINavigationController alloc] initWithRootViewController:con] autorelease];
	[self.navigationController presentModalViewController:navi animated:YES];
}

- (void)checkDeviceIsPaired {
	NSString *macname = [[NSUserDefaults standardUserDefaults] objectForKey:@"macname"];
	NSString *passcode = [[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"];
	if ([macname length] && [passcode length]) {
		isPaired = YES;
	}
	else {
		isPaired = NO;
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"macname"];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"passcode"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	[myTableView reloadData];
}

- (UITableViewCell*)cellObtainFromTableView:(UITableView*)tableView atIndexPath:(NSIndexPath *)indexPath {
	NSString *kCellID = nil;
	if (indexPath.section == 0 && indexPath.row == 0) {
		kCellID = @"cell_attr";
	}
	else {
		kCellID = @"cell_normal";
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell)
		return cell;
	
#ifdef __IPHONE_3_0
	if (indexPath.section == 0 && indexPath.row == 0) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellID] autorelease];
	}
	else {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID] autorelease];
	}
#else
	cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kCellID] autorelease];
#endif
	return cell;
}

#pragma mark -
#pragma mark NSNetServiceBrowserDelegate

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didRemoveService:(NSNetService*)service moreComing:(BOOL)moreComing {	
	DNSLogMethod
	NSString *macname = [[NSUserDefaults standardUserDefaults] objectForKey:@"macname"];
	if ([service.name isEqualToString:macname]) {
		isFound = NO;
		self.pairedService = nil;
		[myTableView reloadData];
	}
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didFindService:(NSNetService*)service moreComing:(BOOL)moreComing {
	DNSLogMethod
	NSString *macname = [[NSUserDefaults standardUserDefaults] objectForKey:@"macname"];
	if ([service.name isEqualToString:macname]) {
		isFound = YES;
		self.pairedService = service;
		[myTableView reloadData];
	}
}

#pragma mark -
#pragma mark NSNetServiceDelegate

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
	DNSLogMethod
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
	DNSLogMethod
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if( [alertView isKindOfClass:[SNAlertViewAccountInput class]] ) {
		UITextField*field1 = ((SNAlertViewAccountInput*)alertView).usernameField;
		UITextField*field2 = ((SNAlertViewAccountInput*)alertView).passwordField;
		if( buttonIndex == 0 ) {
		}
		else if( buttonIndex == 1 ) {
			DNSLog(@"%@-%@", field1.text, field2.text);			
			[UIAppDelegate.keychainWrapper setObject:field1.text forKey:(id)kSecAttrAccount];
			[UIAppDelegate.keychainWrapper setObject:field2.text forKey:(id)kSecValueData];
		}
	}
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	DNSLogMethod
	[self.client stop];
	self.syncController = nil;
	[self.client startServiceBrowser];
	[[SNDownloadManager sharedInstance] removeAllQueue];
}

#pragma mark -
#pragma mark BonjourClientDelegate

- (void)openCompletedStream:(NSStream*)stream {
	DNSLogMethod
	if (self.syncController == nil) {
		self.syncController = [[[SyncingController alloc] initWithDelegate:self] autorelease];
		self.syncController.client = client;
	}
	[self.syncController openCompletedStream:stream];
}

- (void)endEncounteredStream:(NSStream*)stream {
	DNSLogMethod
	[self.client stop];
	self.syncController = nil;
	[self.client startServiceBrowser];
	[[NSNotificationCenter defaultCenter] postNotificationName:kDismissSyncProgressSheet object:nil userInfo:nil];
}

- (void)receivedData:(NSData*)data stream:(NSStream*)stream {
	DNSLogMethod
	if ([self.syncController dispatchData:data stream:stream]) {
	}
	else {
		[self.client stop];
		self.syncController = nil;
		[self.client startServiceBrowser];
	}
}

#pragma mark -
#pragma mark UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#ifdef _ITC_SCRAPING
	return 4;
#else
	return 3;
#endif
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return NSLocalizedString(@"Your Mac", nil);
		case 2:
			return NSLocalizedString(@"Currency rate and Application Info", nil);
		case 3:
			return NSLocalizedString(@"iTunes connect (Debug only)", nil);
		default:
			return nil;
	}
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 2;
	}
	else if (section == 1) {
		if (isFound)
			return 1;
		return 0;
	}
	else if (section == 2) {
		return 1;
	}
	else if (section == 3) {
		return 2;
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 56;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (section == 2) {
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 66)];
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 56)];
		view.backgroundColor = [UIColor clearColor];
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont systemFontOfSize:14];
		label.numberOfLines = 3;
		label.textAlignment = UITextAlignmentCenter;
		label.textColor = [UIColor colorWithRed:76.0/255.0 green:86.0/255.0 blue:108.0/255.0 alpha:1.0];
		label.shadowColor = [UIColor whiteColor];
		label.shadowOffset = CGSizeMake(0, 1);
		label.text = NSLocalizedString(@"You can change currency to display via Setting app.", nil);
		[view addSubview:label];
		[label autorelease];
		return [view autorelease];
	}
	return nil;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell* cell = [self cellObtainFromTableView:tableView atIndexPath:indexPath];
	NSString *macname = [[NSUserDefaults standardUserDefaults] objectForKey:@"macname"];
	
	if (indexPath.section == 0 && indexPath.row == 0) {
		NSString *text = nil;
		NSString *value = nil;
		if (!isPaired) {
			text = NSLocalizedString(@"No pairing Mac", nil);
			value = NSLocalizedString(@"", nil);
		}
		else if (isFound) {
			text = [NSString stringWithFormat:NSLocalizedString(@"%@", nil), macname];
			value = NSLocalizedString(@"online", nil);
		}
		else {
			text = [NSString stringWithFormat:NSLocalizedString(@"%@", nil), macname];
			value = NSLocalizedString(@"offline", nil);
		}
		cell.textLabel.text = text;
		cell.detailTextLabel.text = value;
	}
	else if (indexPath.section == 0 && indexPath.row == 1) {
		if (!isPaired)
			cell.textLabel.text = NSLocalizedString(@"Pairing with Your Mac", nil);
		else 
			cell.textLabel.text = NSLocalizedString(@"Revoke pairing", nil);
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else if (indexPath.section == 1 && indexPath.row == 0) {
		cell.textLabel.text = NSLocalizedString(@"Read all log file from Mac", nil);
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	else if (indexPath.section == 2 && indexPath.row == 0) {
		cell.textLabel.text = NSLocalizedString(@"Reload", nil);
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	else if (indexPath.section == 3 && indexPath.row == 0) {
		cell.textLabel.text = NSLocalizedString(@"Edit ITC account", nil);
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else if (indexPath.section == 3 && indexPath.row == 1) {
		cell.textLabel.text = NSLocalizedString(@"Download from iTunes connect", nil);
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	return cell;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		isPaired = NO;
		isFound = NO;
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"macname"];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"passcode"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[myTableView reloadData];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 0 && isPaired) {
		return YES;
	}
	return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	if (indexPath.section == 0 && indexPath.row == 1) {
		PairingViewController* con = [[PairingViewController alloc] init];
		[self.navigationController pushViewController:con animated:YES];
		[con release];
	}
	else if (indexPath.section == 1 && indexPath.row == 0) {
		[self.client tryToResolveNewService:self.pairedService];
		SyncProgressSheet *sheet = [[SyncProgressSheet alloc] initWithDelegate:self];
		[sheet showInView:UIAppDelegate.window];
		[sheet autorelease];
		[UIAppDelegate deleteAllCachePlist];
	}
	else if (indexPath.section == 2 && indexPath.row == 0) {
		SyncProgressSheet *sheet = [[SyncProgressSheet alloc] initWithDelegate:self];
		[sheet showInView:UIAppDelegate.window];
		[sheet autorelease];
		//
		// Push queues which download and process yahoo data and application icons
		//
		SNDownloadManager *manager = [SNDownloadManager sharedInstance];
		SNDownloadQueue *queue = nil;
		sqlite3 *database = [SQLiteDBController sharedInstance].database;
		
		NSArray *appleIdentifiers = [ITSTool appleIdentifiersFromTargetDatabase:database];
		
		for (NSString *str in appleIdentifiers) {
			DNSLog(@"appleIdentifiers-%@", str);
			queue = [ITSReviewDownloadQueue queueWithAppleIDForApp:[str intValue]];
			[manager addQueue:queue];
		}
		
		queue = [YAHCurrecyCSVDownloadQueue defaultQueue];
		[manager addToTailQueue:queue];
		
		int remained = [appleIdentifiers count] + 1;
		
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  NSLocalizedString(@"Update application info and currency rate...", nil),	kKeyUpdateMessageSyncProgressSheet,
								  [NSNumber numberWithInt:0],							kKeyUpdateProgressSyncProgressSheet,
								  [NSNumber numberWithInt:remained],					kKeyUpdateRemainedSyncProgressSheet,
								  nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:kUpdateSyncProgressSheet object:nil userInfo:userInfo];
		[UIAppDelegate deleteAllCachePlist];
	}
#ifdef _ITC_SCRAPING
	else if (indexPath.section == 3 && indexPath.row == 0) {
		NSString *username = [UIAppDelegate.keychainWrapper objectForKey:(id)kSecAttrAccount];
		NSString *password = [UIAppDelegate.keychainWrapper objectForKey:(id)kSecValueData];
		SNAlertViewAccountInput *view = [[SNAlertViewAccountInput alloc] initWithTitle:NSLocalizedString(@"iTunes connect account", nil ) delegate:self];
		[view show];
		[view release];
		view.usernameField.placeholder = NSLocalizedString(@"Username", nil);
		view.usernameField.text = username;
		view.passwordField.placeholder = NSLocalizedString(@"Password", nil);
		view.passwordField.text = password;
		view.passwordField.secureTextEntry = YES;
	}
	else if (indexPath.section == 3 && indexPath.row == 1) {
		SNActionSheetController* con = [SNActionSheetController sharedInstance];
		[con showInView:UIAppDelegate.window];
		
		SNDownloadManager *manager = [SNDownloadManager sharedInstance];
		SNDownloadQueue *queue = nil;
		//
		// Make and push the queue which downloads sales log file from iTunes connect.
		//
		queue = [ITCLoginPageDownloadQueue defaultQueue];
		[manager addQueue:queue];
	}
#endif
}

#pragma mark -
#pragma mark Override

- (id)init {
	self = [super init];
	myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStyleGrouped];
	myTableView.delegate = self;
	myTableView.dataSource = self;
	[self.view addSubview:myTableView];
	[myTableView release];
	
	self.client = [[BonjourClient alloc] init];
	self.client.searchType = [NSString stringWithFormat:@"_%@._tcp.", @"StoreSales"];
	client.delegate = self;
	[client release];
	[client startServiceBrowser];
	
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStyleDone target:self action:@selector(pushClose:)];
	self.navigationItem.rightBarButtonItem = item;
	[item release];
	
	item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tutorialIcon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(pushHelp:)];
	self.navigationItem.leftBarButtonItem = item;
	[item release];
	
#ifdef _ITC_SCRAPING
#ifdef _DEBUG	
	UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Update", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(pushUpdate:)];
	self.navigationItem.leftBarButtonItem = item2;
	[item2 release];
#endif
#endif
	
	//
	// Set observer, notify after all download queue of DownloadManager
	//
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allDownloadTaskCompleted:) name:kSNDownloadTaskCompleted object:[SNDownloadManager sharedInstance]];
	
	return self;
}

- (void)allDownloadTaskCompleted:(NSNotification*)notification {
	DNSLogMethod
	//
	// Update all application and country flag data
	//
	[[NSNotificationCenter defaultCenter] postNotificationName:kDismissSyncProgressSheet object:nil userInfo:nil];
	[UIAppDelegate reloadAllData];
	DNSLog(@"UsersDefault's currency code = %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"currencyCode"]);
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.title = NSLocalizedString(@"Sync", nil);
	[self checkDeviceIsPaired];
	[self.client restartServiceBrowser];
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	DNSLogMethod
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[client release];
	[syncController release];
	[pairedService release];
    [super dealloc];
}

@end

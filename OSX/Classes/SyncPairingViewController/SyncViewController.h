//
//  SyncViewController.h
//  StoreSalesClient
//
//  Created by sonson on 09/05/06.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StreamManager.h"

@class BonjourClient;
@class SyncingController;

@interface SyncViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, StreamManagerDelegate> {
	BOOL					isPaired;
	BOOL					isFound;
	BonjourClient			*client;
	SyncingController		*syncController;

	NSNetService			*pairedService;
	UITableView				*myTableView;
}
@property (nonatomic, readonly) UITableView *myTableView;
@property (nonatomic, retain) BonjourClient* client;
@property (nonatomic, retain) SyncingController* syncController;
@property (nonatomic, retain) NSNetService* pairedService;
+ (UINavigationController*)defaultController;
- (void)pushClose:(id)sender;
- (void)checkDeviceIsPaired;
- (UITableViewCell*)cellObtainFromTableView:(UITableView*)tableView atIndexPath:(NSIndexPath *)indexPath;
@end

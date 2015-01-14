//
//  SyncProgressSheet.h
//  StoreSales
//
//  Created by sonson on 09/09/27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* kDismissSyncProgressSheet;
extern NSString* kUpdateSyncProgressSheet;
extern NSString* kKeyUpdateMessageSyncProgressSheet;
extern NSString* kKeyUpdateProgressSyncProgressSheet;
extern NSString* kKeyUpdateRemainedSyncProgressSheet;

@interface SyncProgressSheet : UIActionSheet {
	UIProgressView	*progressView;
	int				targetRemained;
	UILabel			*messageLabel;
}

@end

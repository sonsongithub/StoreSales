//
//  SyncProgressSheet.m
//  StoreSales
//
//  Created by sonson on 09/09/27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SyncProgressSheet.h"

NSString* kDismissSyncProgressSheet = @"kDismissSyncProgressSheet";
NSString* kUpdateSyncProgressSheet = @"kUpdateSyncProgressSheet";
NSString* kKeyUpdateMessageSyncProgressSheet = @"kKeyUpdateMessageSyncProgressSheet";
NSString* kKeyUpdateProgressSyncProgressSheet = @"kKeyUpdateProgressSyncProgressSheet";
NSString *kKeyUpdateRemainedSyncProgressSheet = @"kKeyUpdateRemainedSyncProgressSheet";

@implementation SyncProgressSheet

- (id)initWithDelegate:(id)delegate {
	if (self = [super initWithTitle:NSLocalizedString(@"\r\r\r", nil) 
						   delegate:delegate
				  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
			 destructiveButtonTitle:nil
				  otherButtonTitles:nil]) {
		//
		// setup title label
		//
		messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[self addSubview:messageLabel];
		messageLabel.font = [UIFont boldSystemFontOfSize:12];
		messageLabel.textColor = [UIColor whiteColor];
		messageLabel.shadowColor = [UIColor blackColor];
		messageLabel.backgroundColor = [UIColor clearColor];
		messageLabel.shadowOffset = CGSizeMake( 0, -1 );
		messageLabel.textAlignment = UITextAlignmentCenter;
		messageLabel.frame = CGRectMake(0, 0, 320, 44);
		
		//
		// Setup progress view
		//
		progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
		progressView.progress = 0;
		[self addSubview:progressView];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss:) name:kDismissSyncProgressSheet object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update:) name:kUpdateSyncProgressSheet object:nil];
		targetRemained = 1;
		CGRect progressFrame = progressView.frame;
		progressFrame.size.width = 280;
		progressFrame.origin.x = (int)(320 - progressFrame.size.width) / 2;
		progressFrame.origin.y = 50;
		progressView.frame = progressFrame;
	}
	return self;
}

- (void)update:(NSNotification*)notification {
	DNSLogMethod
	NSDictionary *userInfo = [notification userInfo];
	DNSLog(@"%@-%@", kKeyUpdateMessageSyncProgressSheet, [userInfo objectForKey:kKeyUpdateMessageSyncProgressSheet]);
	DNSLog(@"%@-%@", kKeyUpdateProgressSyncProgressSheet, [userInfo objectForKey:kKeyUpdateProgressSyncProgressSheet]);
	
	if ([userInfo objectForKey:kKeyUpdateRemainedSyncProgressSheet]) {
		targetRemained = [[userInfo objectForKey:kKeyUpdateRemainedSyncProgressSheet] intValue];
	}
	
	messageLabel.text = [userInfo objectForKey:kKeyUpdateMessageSyncProgressSheet];
	int alreadyStepped = [[userInfo objectForKey:kKeyUpdateProgressSyncProgressSheet] intValue];
	if (targetRemained > 0) {
		progressView.progress = (float)(targetRemained - alreadyStepped) / (float)targetRemained;
	}
	else {
		progressView.progress = 0;
	}
	DNSLog(@"%@", userInfo);
}

- (void)dismiss:(NSNotification*)notification {
	[super dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[progressView release];
	[messageLabel release];
    [super dealloc];
}


@end

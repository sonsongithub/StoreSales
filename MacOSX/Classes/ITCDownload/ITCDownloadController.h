//
//  ITCDownloadController.h
//  StoreSales
//
//  Created by sonson on 09/06/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ITCProgressWindowController.h"

@class ITCProgressWindowController;

extern NSString* kITCDownloadControllerDownloadCount;
extern NSString* kITCDownloadDailyCountKey;
extern NSString* kITCDownloadWeeklyCountKey;
extern NSString* kITCDownloadCountKey;

@interface ITCDownloadController : NSObject <ITCProgressWindowControllerDelegate> {
	ITCProgressWindowController *windowController;
	int previousNumberOfDailyLogs;
	int previousNumberOfWeeklyLogs;
	
	int numberOfDailyLogs;
	int numberOfWeeklyLogs;
}

#pragma mark Instance method
- (void)startDownloadLog;
- (void)allDownloadTaskCompleted:(NSNotification*)notification;
- (void)willCancelDownload;

@end

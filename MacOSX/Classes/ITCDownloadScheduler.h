//
//  ITCDownloadScheduler.h
//  StoreSales
//
//  Created by sonson on 09/11/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ITCDownloadScheduler : NSObject {
	BOOL			isPeriodicalChecked;
	NSTimeInterval	periodicalTime;
	NSTimer			*periodCheckTimer;
	NSTimer			*taskTimer;
}
+ (ITCDownloadScheduler*)sharedInstance;
- (void)validate;
- (void)invalidate;
@end

//
//  ITSReviewDownloadQueue.h
//  StoreSales
//
//  Created by sonson on 09/05/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNDownloadQueue.h"

@interface ITSReviewDownloadQueue : SNDownloadQueue {
	int			appleID;
	NSString	*countryCode;
}
@property (nonatomic, assign) int appleID;
@property (nonatomic, retain) NSString *countryCode;
+ (ITSReviewDownloadQueue*)queueWithAppleIDForApp:(int)AppleID;
@end

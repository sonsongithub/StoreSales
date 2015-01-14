//
//  ITCSalesPage.h
//  StoreSales
//
//  Created by sonson on 10/09/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNDownloadQueue.h"


@interface ITCSalesPage : SNDownloadQueue {
}
+ (ITCSalesPage*)defaultQueue;
+ (ITCSalesPage*)queueWithURLString:(NSString*)urlString;
@end

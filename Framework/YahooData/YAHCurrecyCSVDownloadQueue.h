//
//  YAHCurrecyCSVDownloadQueue.h
//  StoreSales
//
//  Created by sonson on 09/05/26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNDownloadQueue.h"

@interface YAHCurrecyCSVDownloadQueue : SNDownloadQueue {
}
+ (YAHCurrecyCSVDownloadQueue*)defaultQueue;
@end

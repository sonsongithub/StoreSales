//
//  ITSIconImageDownloadQueue.h
//  StoreSales
//
//  Created by sonson on 09/05/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNDownloadQueue.h"

@interface ITSIconImageDownloadQueue : SNDownloadQueue {
		int appleID;
}
@property (nonatomic, assign) int appleID;
@end

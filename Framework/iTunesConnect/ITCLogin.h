//
//  ITCLogin.h
//  StoreSales
//
//  Created by sonson on 10/09/09.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNDownloadQueue.h"

@interface ITCLogin : SNDownloadQueue {
}
+ (ITCLogin*)queueWithActionURLString:(NSString*)actionURLString;
@end

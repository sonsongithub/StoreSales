//
//  ITCDownloader.h
//  StoreSales
//
//  Created by sonson on 11/08/25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITCDownloader : NSObject

+ (ITCDownloader *)sharedManager;

- (void)downloadReports;

@end

//
//  FileSendQueueController.h
//  StoreSales
//
//  Created by sonson on 09/06/03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileSendQueueController : NSObject {
	NSMutableArray	*queue;
	int				remained;
	int				already;
}
@property (nonatomic, retain) NSMutableArray *queue;
@property (nonatomic, readonly) int remained;
@property (nonatomic, readonly) int already;
- (NSData*)popQueue;
@end

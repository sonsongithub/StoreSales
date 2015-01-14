//
//  SNDownloadQueue.h
//  StoreSales
//
//  Created by sonson on 09/05/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	DownloadQueueDone = 0,
	DownloadQueueCancelled = 1,
	DownloadQueueError = 2
}DownloadManagerResult;

@interface SNDownloadQueue : NSObject {
	id						target;
	SEL						selector;
	NSURL					*url;
	NSURLRequest			*request;
	NSURLResponse			*response;
	DownloadManagerResult	result;
	NSError					*resultError;
}

@property (nonatomic, retain) id target;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) DownloadManagerResult result;
@property (nonatomic, retain) NSError *resultError;

+ (SNDownloadQueue*)queueFromURL:(NSURL*)URL;
+ (SNDownloadQueue*)queueFromURLRequest:(NSURLRequest*)URLRequest;

- (void)doTaskAfterDownloadingData:(NSData*)data;
- (void)doTaskAfterFailedDownload:(NSError*)error;

@end

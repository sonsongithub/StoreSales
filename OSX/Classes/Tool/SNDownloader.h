//
//  SNDownloader.h
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *kSNDownloaderCancel;

@protocol SNDownloaderDelegate
- (void) didFinishLoading:(id)data;
- (void) didFinishLoading:(id)data response:(NSHTTPURLResponse*)response;
- (void) didCancelLoadingResponse:(NSHTTPURLResponse*)response;
- (void) didFailLoadingWithError:(NSError *)error;
- (void) didCacheURLLoading;
- (void) didDifferenctURLLoading;
@end

@interface SNURLConnection : NSURLConnection {
	id delegate;
}
@property (nonatomic, retain) id delegate;
@end

@interface SNDownloader : NSObject {
	id					delegate;
	SNURLConnection		*connection;
	NSMutableData		*savedData;
	int					sizeToRecieve;
	NSURLRequest		*request;
	NSHTTPURLResponse	*httpURLResponse;
	BOOL				enableErrorMessage;
	SEL					callback;
}
@property (nonatomic, retain) id delegate;
@property (nonatomic, assign) SNURLConnection *connection;
@property (nonatomic, retain) NSMutableData *savedData;
@property (nonatomic, assign) int sizeToRecieve;
@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) NSHTTPURLResponse *httpURLResponse;
@property (nonatomic, assign) BOOL enableErrorMessage;
@property (nonatomic, assign) SEL callback;
- (id)initWithDelegate:(id)delegate;
- (void)cancel;
- (void)startWithRequest:(NSURLRequest*)request;
@end

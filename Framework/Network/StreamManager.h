//
//  StreamManager.h
//  StoreSales
//
//  Created by sonson on 09/05/19.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define READ_CHACHE_BYTE	1024

// protocol for StreamManager delegate methods
@protocol StreamManagerDelegate <NSObject>
@optional
- (void)openCompletedStream:(NSStream*)stream;
- (void)endEncounteredStream:(NSStream*)stream;
- (void)receivedData:(NSData*)data stream:(NSStream*)stream;
@end

// class definition
@interface StreamManager : NSObject
#if TARGET_OS_IPHONE	// a couple of protocols are not implemented on MacOSX
<NSStreamDelegate>
#else
<NSStreamDelegate>
#endif
{
	NSInputStream		*inStream;
	NSOutputStream		*outStream;
	
	u_int32_t			lengthToReceive;
	NSMutableData		*receivedData;	
	id <StreamManagerDelegate>
	delegate;
}
@property (nonatomic, retain) NSInputStream *inStream;
@property (nonatomic, retain) NSOutputStream *outStream;
@property (nonatomic, assign) id <StreamManagerDelegate> delegate;
@property (nonatomic, assign) u_int32_t lengthToReceive;
@property (nonatomic, retain) NSMutableData *receivedData;

#pragma mark -
#pragma mark Stream Controller
- (void)openStreams;
- (void)closeStreams;
#pragma mark -
#pragma mark Send
- (void)sendData:(NSData*)data;
#pragma mark -
#pragma mark NSStreamRead Help Tool
- (u_int32_t)extractLengthToReceiveFromStream:(NSInputStream*)anInStream;
- (void)appendBytesToData:(NSData*)data fromStream:(NSInputStream*)anInStream;
- (void)finalizeCurrentReadBuffer:(NSStream*)stream;
@end

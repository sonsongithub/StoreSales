//
//  StreamManager.m
//  StoreSales
//
//  Created by sonson on 09/05/19.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StreamManager.h"

@implementation StreamManager

@synthesize inStream, outStream;
@synthesize lengthToReceive, receivedData;
@synthesize delegate;

#pragma mark -
#pragma mark Stream Controller

- (void)openStreams {
	DNSLogMethod
	self.inStream.delegate = self;
	[self.inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.inStream open];
	self.outStream.delegate = self;
	[self.outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.outStream open];
}

- (void)closeStreams {
	DNSLogMethod
	[inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[inStream close];
	DNSLog(@"inStream - will release, %d", [inStream retainCount]);
//	self.inStream.delegate = nil;
	self.inStream = nil;
	
	[outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outStream close];
	DNSLog(@"outStream - will release, %d", [outStream retainCount]);
//	self.outStream.delegate = nil;
	self.outStream = nil;
}

#pragma mark -
#pragma mark Send

- (void)sendData:(NSData*)data {
	DNSLogMethod
	// calc length of the whole bytes to send
	u_int32_t lengthToSend = [data length];
	lengthToSend += sizeof(lengthToSend);
	
	// make NSData to send
	NSMutableData *dataToSend = [NSMutableData data];	
	[dataToSend appendBytes:&lengthToSend length:sizeof(lengthToSend)];
	[dataToSend appendData:data];
	
	// try to send
	int sentLength = 0;
	while(sentLength < lengthToSend) {
		// continue to send until all bytes had been sent reaches bytes length to send.
		sentLength += [self.outStream write:[dataToSend bytes]+sentLength maxLength:[dataToSend length]-sentLength];
		if ([self.outStream streamStatus] != kCFStreamStatusOpen ) {
			break;
		}
	}
}

#pragma mark -
#pragma mark NSStreamRead Help Tool

- (u_int32_t)extractLengthToReceiveFromStream:(NSInputStream*)anInStream {
	DNSLogMethod
	// read the head 4bytes from stream
	// this is bytes length to receive from remote
	unsigned int len = 0;
	u_int32_t length;
	
	// copy to <length>
	len = [self.inStream read:(u_int8_t*)&length maxLength:sizeof(length)];
	if (len != sizeof(length)) {
		// if bytes to be wrote is different from expected bytes length
		// it's error.
		lengthToReceive = 0;
		self.receivedData = nil;
		return 0;
	}
	
	// subtract own bytes
	return length - sizeof(u_int32_t);
}

- (void)appendBytesToData:(NSData*)data fromStream:(NSInputStream*)anInStream {
	// append incomming bytes
	unichar buffer[READ_CHACHE_BYTE];
	unsigned int len = 0;
	while(1) {
		len = 0;
		len = [self.inStream read:(uint8_t*)buffer maxLength:sizeof(buffer)];
		if (len > 0 && len <= sizeof(buffer)) {
			[self.receivedData appendBytes:buffer length:len];
		}
		if (len == 0) {
			if ([self.inStream streamStatus] == NSStreamStatusAtEnd) {
				break;
			}
			else {
				self.receivedData = nil;
				break;
			}
		}
		if (![self.inStream hasBytesAvailable]) {
			break;
		}
	}
}

- (void)finalizeCurrentReadBuffer:(NSStream*)stream {
	// check if bytes to receive have reached to target length
	if ([self.receivedData length] == lengthToReceive) {
		// reached to lengthToReceive
		DNSLog(@"NSStreamEventHasBytesAvailable");
		if ([self.receivedData length] > 0) {
			// call delegate method to pass NSData instance as received bytes
			if ([self.delegate respondsToSelector:@selector(receivedData:stream:)]) {
				[self.delegate receivedData:self.receivedData stream:stream];
			}
		}
		else {
			// call end of stream. because 0 bytes packet has come.
			if ([self.delegate respondsToSelector:@selector(endEncounteredStream:)]) {
				[self.delegate endEncounteredStream:stream];
			}
			// close currenet own streams
			[self closeStreams];
		}
		// clear buffer
		self.receivedData = nil;
		lengthToReceive = 0;
	}
}

#pragma mark -
#pragma mark NSStreamDelegate

- (void)stream:(NSStream*)stream handleEvent:(NSStreamEvent)eventCode {
	DNSLogMethod
	// copy bytes avaiable from streaam into the own current buffer
	if (eventCode == NSStreamEventHasBytesAvailable) {
		DNSLog(@"NSStreamEventHasBytesAvailable");
		if (stream == self.inStream) {
			if (lengthToReceive == 0 && self.receivedData == nil) {
				// currently, buffer is vacant.
				// set bytes length which is comming from remote
				// set mutable bytes, make new buffer
				self.receivedData = [NSMutableData data];
	
				// append incomming bytes and bytes length to receive is extracted from head 4bytes.
				self.lengthToReceive = [self extractLengthToReceiveFromStream:self.inStream];
				[self appendBytesToData:self.receivedData fromStream:self.inStream];
				
				DNSLog(@"------>Bytes to receive - %d/%d bytes", [self.receivedData length], lengthToReceive);
				
				//DNSLog(@"%@", [NSString stringAutoDecodeBytesFrom:[self.receivedData bytes] length:[self.receivedData length]]);
				// check read out stream?
				[self finalizeCurrentReadBuffer:stream];
			}
			else if (lengthToReceive > 0 && self.receivedData != nil) {
				// append incomming bytes
				[self appendBytesToData:self.receivedData fromStream:self.inStream];
				
				DNSLog(@"Bytes to receive - %d/%d bytes", [self.receivedData length], lengthToReceive);
				
				// check read out stream?
				[self finalizeCurrentReadBuffer:stream];
			}
		}
	}
	
	// dispatch the other stream event to delegate target.
	switch(eventCode) {
		case NSStreamEventOpenCompleted:
			DNSLog(@"NSStreamEventOpenCompleted");
			// openning stream has just completed
			if ([self.delegate respondsToSelector:@selector(openCompletedStream:)]) {
				[self.delegate openCompletedStream:stream];
			}
			break;
		case NSStreamEventEndEncountered:
			DNSLog(@"NSStreamEventEndEncountered");
			// openning stream has just closed
			if ([self.delegate respondsToSelector:@selector(endEncounteredStream:)]) {
				[self.delegate endEncounteredStream:stream];
			}
			[self closeStreams];
			break;
	}
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	DNSLogMethod
	[self closeStreams];
	[inStream release];
	[outStream release];
	[receivedData release];
	[super dealloc];
}

@end

//
//  FileSendQueueController.m
//  StoreSales
//
//  Created by sonson on 09/06/03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FileSendQueueController.h"

// iTunes connect tool
#import "ITCTool.h"
#import "ITCLogParser.h"

// Tool
#import "SQLiteDBController.h"
#import "FileSendXMLMaker.h"


#if TARGET_OS_IPHONE
#else
#import "FileSendWindowController.h"
#endif

// Queue, dictionary keys.
NSString* kLogFileQueuePath = @"kLogFileQueuePath";
NSString* kLogFileDateString = @"kLogFileDateString";

@implementation FileSendQueueController

@synthesize queue, already, remained;

- (NSData*)popQueue {
	NSDictionary *queueDict = [self.queue lastObject];
	
	if (queueDict == nil) {
		return nil;
	}
	
	NSString *path = [queueDict objectForKey:kLogFileQueuePath];
	//	NSString *fileName = [queueDict objectForKey:kLogFileDateString];
	
	NSData *data = [NSData dataWithContentsOfFile:path];
	ITCLogType type = ITCLogUnknown;
	ITCLogVersion versionType = ITCLogVersion10;
	NSDate *beginDate = nil;
	NSDate *endDate = nil;
	
	DNSLog(@"Queue=%d", [self.queue count]);
	DNSLog(@"Try to send =%dbytes", [data length]);
	
	if ([ITCLogParser isITCLog:data logType:&type versionType:&versionType beginDate:&beginDate endDate:&endDate]) {
		
		if (type == ITCLogDaily) {
			DNSLog(@"ITCLogDaily - %@, %@", beginDate, endDate);
			NSDateFormatter *format = [[NSDateFormatter alloc] init];
			[format setDateFormat:@"MM/dd/yyyy"];
#if TARGET_OS_IPHONE
#else
			// Update progress message
			NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Daily data %@", nil), [format stringFromDate:beginDate]];
			NSDictionary *dict = [NSDictionary dictionaryWithObject:message forKey:kFileSendWindowKeyForUpdateMessage];
			[[NSNotificationCenter defaultCenter] postNotificationName:kFileSendWindowUpdateProgress object:nil userInfo:dict];
#endif
			[format release];
		}
		else if (type == ITCLogWeekly) {
			DNSLog(@"ITCLogWeekly - %@, %@", beginDate, endDate);
			NSDateFormatter *format = [[NSDateFormatter alloc] init];
			[format setDateFormat:@"MM/dd/yyyy"];
#if TARGET_OS_IPHONE
#else
			// Update progress message
			NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Weekly data %@", nil), [format stringFromDate:beginDate]];
			NSDictionary *dict = [NSDictionary dictionaryWithObject:message forKey:kFileSendWindowKeyForUpdateMessage];
			[[NSNotificationCenter defaultCenter] postNotificationName:kFileSendWindowUpdateProgress object:nil userInfo:dict];
#endif
			[format release];
		}
		else {
			[self.queue removeLastObject];
			return [self popQueue];
		}
		if (![ITCLogParser isArlreadSentDataWithLogType:type beginDate:beginDate endDate:endDate targetDB:[SQLiteDBController sharedInstance].database]) {
			NSData *dataToSend = [FileSendXMLMaker XMLToSendData:data filepath:[path lastPathComponent] remained:remained already:remained-[self.queue count]];
			[self.queue removeLastObject];
			return dataToSend;
		}
		else {
			[self.queue removeLastObject];
			return [self popQueue];
		}
	}
	[self.queue removeLastObject];
	return [self popQueue];
}

- (void)makeQueue {
	DNSLogMethod
	// Make buffer
	self.queue = [NSMutableArray array];
	
	// Make date formatter for making string to use as message
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	
	//
	// Make file list
	//
	BOOL isDir = NO;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"logFileFolderPath"];
	NSArray *array = [fileManager contentsOfDirectoryAtPath:path error:nil];
	//
	// Make queues
	//
	for (NSString* s in array) {
		NSString *tempPath = [path stringByAppendingPathComponent:s];
		[fileManager fileExistsAtPath:tempPath isDirectory:&isDir];
		if (!isDir) {
			NSData *data = [NSData dataWithContentsOfFile:tempPath];
			ITCLogType type = ITCLogUnknown;
			ITCLogVersion versionType = ITCLogVersion10;
			NSDate *beginDate = nil;
			NSDate *endDate = nil;
			
			if ([ITCLogParser isITCLog:data logType:&type versionType:&versionType beginDate:&beginDate endDate:&endDate]) {
				//
				// This file is iTunes connect sales log
				//
				if (![ITCLogParser isArlreadSentDataWithLogType:type beginDate:beginDate endDate:endDate targetDB:[SQLiteDBController sharedInstance].database]) {
					//
					// This file hasn't been sent to iPhone yet.
					//
					NSString *descriptionString = nil;
					if (type == ITCLogDaily) {
						descriptionString = [NSString stringWithFormat:NSLocalizedString(@"Send log for Daily:%@", nil), [dateFormatter stringFromDate:beginDate]];
					}
					else if (type == ITCLogWeekly) {
						descriptionString = [NSString stringWithFormat:NSLocalizedString(@"Send log for Weekly:%@", nil), [dateFormatter stringFromDate:beginDate]];
					}
					else {
					}
					NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:descriptionString, kLogFileDateString, tempPath, kLogFileQueuePath, nil];
					[self.queue addObject:dict];
					// DNSLog(@"Added %@", dict);
				}
			}
		}
	}
	remained = [self.queue count];
}

- (id)init {
	DNSLogMethod
	self = [super init];
	[self makeQueue];
	return self;
}

- (void) dealloc {
	DNSLogMethod
	[queue release];
	[super dealloc];
}

@end

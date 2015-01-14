//
//  SyncingController.m
//  StoreSalesClient
//
//  Created by sonson on 09/05/15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SyncingController.h"
#import "PairingXMLParser.h"

#import "UICNSData+AES256.h"
#import "NSString+digest.h"
#import "GTMBase64.h"

#import "ITCLogParser.h"
#import "SQLiteDBController.h"

#import "SNDownloadManager.h"
#import "YAHCurrecyCSVDownloadQueue.h"
#import "ITSTool.h"
#import "ITSReviewDownloadQueue.h"

#import "SyncProgressSheet.h"

@implementation SyncingController

@synthesize client;

#pragma mark -
#pragma mark Class method

+ (SyncingController*)defaultController {
	DNSLogMethod
	SyncingController *con = [[SyncingController alloc] init];
	return [con autorelease];
}

#pragma mark -
#pragma mark init

- (id)initWithDelegate:(id)delegate {
	self = [super init];
	
	didFailed = NO;
	isNeedUpdateCurrencyAndAppInfo = NO;
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  NSLocalizedString(@"Connecting...", nil),		kKeyUpdateMessageSyncProgressSheet,
							  [NSNumber numberWithInt:0],					kKeyUpdateProgressSyncProgressSheet,
							  nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:kUpdateSyncProgressSheet object:nil userInfo:userInfo];
	
	return self;
}

#pragma mark -
#pragma mark XML Maker

- (NSData*)requestStartXML {
	// to confirm if Mac permit to send files to iPhone
	UIDevice *device = [UIDevice currentDevice];
	NSString *u_identifier = [device uniqueIdentifier];
	NSString *identifier = [u_identifier MD5DigestString];
	
	NSMutableString *xml = [NSMutableString string];
	[xml appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
	[xml appendString:@"<StoreSales>"];
	[xml appendFormat:@"<status>requestCheck</status>"];
	[xml appendFormat:@"<udid>%@</udid>", identifier];
	[xml appendString:@"</StoreSales>"];
	return [xml dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData*)requestXML {
	// to request to start to send files
	UIDevice *device = [UIDevice currentDevice];
	NSString *u_identifier = [device uniqueIdentifier];
	NSString *identifier = [u_identifier MD5DigestString];
	
	NSMutableString *xml = [NSMutableString string];
	[xml appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
	[xml appendString:@"<StoreSales>"];
	[xml appendFormat:@"<status>requestStart</status>"];
	[xml appendFormat:@"<udid>%@</udid>", identifier];
	[xml appendString:@"</StoreSales>"];
	return [xml dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData*)requestNextXML {
	// to request next file after receiving
	UIDevice *device = [UIDevice currentDevice];
	NSString *u_identifier = [device uniqueIdentifier];
	NSString *identifier = [u_identifier MD5DigestString];
	
	NSMutableString *xml = [NSMutableString string];
	[xml appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
	[xml appendString:@"<StoreSales>"];
	[xml appendFormat:@"<status>request</status>"];
	[xml appendFormat:@"<udid>%@</udid>", identifier];
	[xml appendString:@"</StoreSales>"];
	return [xml dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData*)requestNextXMLAndResultCurrent:(ITCDBResult)result type:(ITCLogType)type beginDate:(NSDate*)beginDate endDate:(NSDate*)endDate {
	// to request next file after receiving
	UIDevice *device = [UIDevice currentDevice];
	NSString *u_identifier = [device uniqueIdentifier];
	NSString *identifier = [u_identifier MD5DigestString];
	
	NSMutableString *xml = [NSMutableString string];
	[xml appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
	[xml appendString:@"<StoreSales>"];
	[xml appendFormat:@"<status>request</status>"];
	[xml appendFormat:@"<udid>%@</udid>", identifier];
	
	//
	// Previous sending result
	//
	if (result == ITCDBReulstOK) {
		[xml appendFormat:@"<prev_result>OK</prev_result>"];
	}
	else if (result == ITCDBReulstErrorAlreadyInserted) {
		[xml appendFormat:@"<prev_result>AlreadyInserted</prev_result>"];
	}
	else {
		[xml appendFormat:@"<prev_result>Error</prev_result>"];
	}
	
	// Add previous sending data type
	if (type == ITCLogDaily) {
		[xml appendFormat:@"<prev_type>daily</prev_type>"];
	}
	else if (type == ITCLogWeekly) {
		[xml appendFormat:@"<prev_type>weekly</prev_type>"];
	}
	else  {
		[xml appendFormat:@"<prev_type>unknown</prev_type>"];
	}
	
	// Add previous sending data timestamp info.
	[xml appendFormat:@"<prev_beginDate>%d</prev_beginDate>", (int)[beginDate timeIntervalSinceReferenceDate]];
	[xml appendFormat:@"<prev_endDate>%d</prev_endDate>", (int)[endDate timeIntervalSinceReferenceDate]];
	
	[xml appendString:@"</StoreSales>"];
	return [xml dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark -
#pragma mark Send data

- (void)sendData:(NSData*)data {
	DNSLogMethod
	NSString *key = [[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"];
	NSData *encryptedData = [data dataEncryptedWithKey:key];
	[self.client sendData:encryptedData];
}

- (void)sendRequest {
	DNSLogMethod
	if (self.client.outStream && [self.client.outStream hasSpaceAvailable]) {
		NSData *data = [self requestStartXML];
		[self sendData:data];
	}
}

#pragma mark -
#pragma mark BonjourClientDelegate

- (void)openCompletedStream:(NSStream*)stream {
	DNSLogMethod
	[self sendRequest];
	isNeedUpdateCurrencyAndAppInfo = NO;
}

- (BOOL)dispatchData:(NSData*)data stream:(NSStream*)stream {
	DNSLogMethod
	BOOL dispatchResult = YES;
	//
	// Recieved XML, at first decrypt NSData with passcode
	//
	NSString *key = [[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"];
	NSData *decryptedData = [data dataDecryptedWithKey:key];
	
	if (decryptedData == nil) {
		decryptedData = [data dataDecryptedWithKey:@"d38jslajd8d"];
	}
	
	//
	// Parse XML
	//
	PairingXMLParser* parser = [[PairingXMLParser alloc] init];
	[parser parse:decryptedData];
//	[parser dump];
	
	NSString *status = [parser.dictionary objectForKey:@"status"];
	DNSLog(@"status = %@", status);
	if ([status isEqualToString:@"requestOK"]) {
		//
		// Send XML which has prepared to receive files
		//
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  NSLocalizedString(@"Synchronizing with your Mac", nil),		kKeyUpdateMessageSyncProgressSheet,
								  [NSNumber numberWithInt:0],									kKeyUpdateProgressSyncProgressSheet,
								  nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:kUpdateSyncProgressSheet object:nil userInfo:userInfo];
		
		NSData *data = [self requestXML];
		[self sendData:data];
	}
	else if ([status isEqualToString:@"send"]) {
		//
		// Received XML which includes real data
		//
		//
		// Parse basic text data from XML
		//
		int already = [[parser.dictionary objectForKey:@"already"] intValue];
		int remained = [[parser.dictionary objectForKey:@"remained"] intValue];
		DNSLog(@"%d/%d", already, remained);
		
		//
		// Parse get NSData and decode base64
		//
		sqlite3 *database = [SQLiteDBController sharedInstance].database;
		NSString *stringBase64 = [parser.dictionary objectForKey:@"data"];
		NSData *decodedBase64Data = [GTMBase64 decodeString:stringBase64];
		
		NSDate *beginDate = nil;
		NSDate *endDate = nil;
		ITCLogType type = 0;
		ITCLogVersion version = 0;
		ITCDBResult dbResult = [ITCLogParser insertThisData:decodedBase64Data  targetDB:database beginDate:&beginDate endDate:&endDate logType:&type logVersion:&version];
		DNSLog(@"ITCDBResult=%d", dbResult);
		
#ifdef _DEBUG
		//
		// wrote file for debug
		//
		int databytes = [[parser.dictionary objectForKey:@"databytes"] intValue];
		NSString *filename = [parser.dictionary objectForKey:@"filename"];
		DNSLog(@"%@, data=%dbytes databytes=%dbytes", filename, [decodedBase64Data length], databytes);
#if 0		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
		if( [decodedBase64Data writeToFile:path atomically:NO]) {
			DNSLog(@"Written Path = %@", path);
		}
#endif
#endif
		//
		// Update progress action sheet
		//
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  NSLocalizedString(@"Synchronizing with your Mac", nil),	kKeyUpdateMessageSyncProgressSheet,
								  [NSNumber numberWithInt:remained - already],				kKeyUpdateProgressSyncProgressSheet,
								  [NSNumber numberWithInt:remained],						kKeyUpdateRemainedSyncProgressSheet,
								  nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:kUpdateSyncProgressSheet object:nil userInfo:userInfo];
		
		//
		// Send XML which has means that receiving last file has been successed.
		//
		NSData *data = [self requestNextXMLAndResultCurrent:dbResult type:type beginDate:beginDate endDate:endDate];
		// NSData *data = [self requestNextXML];
		[self sendData:data];
	}
	else if ([status isEqualToString:@"TaskFinished"]) {
		isNeedUpdateCurrencyAndAppInfo = YES;
		didFailed = YES;
		dispatchResult = NO;
	}
	else if ([status isEqualToString:@"AuthorizationFailed"]) {
		dispatchResult = NO;
		if (!didFailed) {
			UIAlertView *view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
														   message:NSLocalizedString(@"AuthorizationFailed", nil)
														  delegate:self
												 cancelButtonTitle:nil
												 otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
			[view show];
			[view release];
		}
		didFailed = YES;
	}
	[parser release];
	return dispatchResult;
}

- (void)endEncounteredStream:(NSStream*)stream {
	DNSLogMethod
}

#pragma mark -
#pragma mark dealloc

- (void) dealloc {
	DNSLogMethod
	
	if (isNeedUpdateCurrencyAndAppInfo) {
		//
		// Push queues which download and process yahoo data and application icons
		//
		SNDownloadManager *manager = [SNDownloadManager sharedInstance];
		SNDownloadQueue *queue = nil;
		sqlite3 *database = [SQLiteDBController sharedInstance].database;
		
		NSArray *appleIdentifiers = [ITSTool appleIdentifiersFromTargetDatabase:database];
		
		DNSLog(@"%@", appleIdentifiers);
		
		for (NSString *str in appleIdentifiers) {
			DNSLog(@"appleIdentifiers-%@", str);
			queue = [ITSReviewDownloadQueue queueWithAppleIDForApp:[str intValue]];
			[manager addQueue:queue];
		}
		
		int remained = [appleIdentifiers count] + 1;
		
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  NSLocalizedString(@"Update application info and currency rate...", nil),	kKeyUpdateMessageSyncProgressSheet,
								  [NSNumber numberWithInt:0],							kKeyUpdateProgressSyncProgressSheet,
								  [NSNumber numberWithInt:remained],					kKeyUpdateRemainedSyncProgressSheet,
								  nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:kUpdateSyncProgressSheet object:nil userInfo:userInfo];
	}
	else {
		[[NSNotificationCenter defaultCenter] postNotificationName:kDismissSyncProgressSheet object:nil userInfo:nil];
		
		if (!didFailed) {
			UIAlertView *view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
														   message:NSLocalizedString(@"Disconnected", nil)
														  delegate:self
												 cancelButtonTitle:nil
												 otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
			[view show];
			[view release];
		}
	}
	
	[super dealloc];
}


@end

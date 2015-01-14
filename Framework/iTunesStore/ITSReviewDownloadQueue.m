//
//  ITSReviewDownloadQueue.m
//  StoreSales
//
//  Created by sonson on 09/05/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ITSReviewDownloadQueue.h"
#import "UICNSString+AutoDecoder.h"
#import "ITSIconImageDownloadQueue.h"
//#import "NSString+iTunesWebPageParse.h"

#import "SNDownloadManager.h"

#if TARGET_OS_IPHONE | TARGET_IPHONE_SIMULATOR
#import "SyncProgressSheet.h"
#endif

@implementation ITSReviewDownloadQueue

@synthesize appleID, countryCode;

+ (ITSReviewDownloadQueue*)queueWithAppleIDForApp:(int)AppleID {
	DNSLogMethod
	
	NSString *areaCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
	
	NSString *baseURLString = @"http://itunes.apple.com/app/id%d";
	
	NSString *URLString = [NSString stringWithFormat:baseURLString, AppleID];
	DNSLog(@"%@", URLString);
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];

	ITSReviewDownloadQueue* queue = [[ITSReviewDownloadQueue alloc] init];
	queue.request = req;
	queue.appleID = AppleID;
	queue.countryCode = areaCode;
	return [queue autorelease];
}

#pragma mark -

- (void)doTaskAfterDownloadingData:(NSData*)data {
	DNSLogMethod
	//
	// Extract image URL
	//
	NSString *html = [NSString stringAutoDecodeFromData:data];
	NSString *imageURL = [html extractiTunesWebPageImageURL];
	
	NSLog(@"Icon URL = %@", imageURL);
	
	if ([imageURL length] > 0) {
		//
		// Push the queue which downloads its application icon image.
		//
		SNDownloadManager *manager = [SNDownloadManager sharedInstance];
		ITSIconImageDownloadQueue *queue = [[ITSIconImageDownloadQueue alloc] init];
		queue.url = [NSURL URLWithString:imageURL];
		queue.appleID = self.appleID;
		[manager addQueue:queue];
		[queue release];
	}
	else if (![self.countryCode isEqualToString:@"us"]) {
	}
	
#if TARGET_OS_IPHONE | TARGET_IPHONE_SIMULATOR
	SNDownloadManager *manager = [SNDownloadManager sharedInstance];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  NSLocalizedString(@"Update application info and currency rate...", nil),	kKeyUpdateMessageSyncProgressSheet,
							  [NSNumber numberWithInt:[manager.queueStack count]],							kKeyUpdateProgressSyncProgressSheet,
							  nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:kUpdateSyncProgressSheet object:nil userInfo:userInfo];
#endif
}

- (void)doTaskAfterFailedDownload:(NSError*)error {
	DNSLogMethod
#if TARGET_OS_IPHONE | TARGET_IPHONE_SIMULATOR
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
													message:NSLocalizedString(@"Please retry to reload info later.", nil)
												   delegate:nil
										  cancelButtonTitle:nil
										  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
	[alert show];
	[alert release];
#endif
}

- (void)dealloc {
    [countryCode release];
    [super dealloc];
}

@end

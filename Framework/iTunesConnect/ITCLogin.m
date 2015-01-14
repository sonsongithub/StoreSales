//
//  ITCLogin.m
//  StoreSales
//
//  Created by sonson on 10/09/09.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ITCLogin.h"
#import "ITCTool.h"
#import "KeychainAccessor.h"
#import "NSDictionary+URLArgments.h"

#import "SNDownloadManager.h"
#import "ITCSalesPage.h"
#import "UICNSString+AutoDecoder.h"

@implementation ITCLogin

+ (ITCLogin*)queueWithActionURLString:(NSString*)actionURLString {
	DNSLogMethod
	ITCLogin *queue = [[[ITCLogin alloc] init] autorelease];
	
	//
	// Make base URL
	//
	NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/%@", @"https://itunesconnect.apple.com", actionURLString];
	DNSLog(@"%@", urlString);
	
	//
	// Obtain username and password
	//
#if TARGET_OS_IPHONE
	//
	// Restore user name from keychain
	//
	// NSString *username = [UIAppDelegate.keychainWrapper objectForKey:(id)kSecAttrAccount];
	// NSString *password = [UIAppDelegate.keychainWrapper objectForKey:(id)kSecValueData];
#else
	//
	// Restore user name from NSUserDefault
	//
	NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"iTunesConnectUserName"];
	NSString *password = [KeychainAccessor passwordForService:@"iTunesConnectStoreSales" account:username];
	[NSApp activateIgnoringOtherApps:YES];
#endif
	if (username == nil || password == nil) {
		// vacant.
		return nil;
	}
	
	//
	// Make URL
	//
	NSDictionary *loginDict = [NSDictionary dictionaryWithObjectsAndKeys:username, @"theAccountName", password, @"theAccountPW", @"0", @"1.Continue.x", @"0", @"1.Continue.y", nil];
	[urlString appendString:[loginDict URLArgments]];
	
	//
	// Make and return URLRequest
	//
	NSURL *loginURL = [NSURL URLWithString:urlString];
	NSMutableURLRequest *loginRequest = [NSMutableURLRequest requestWithURL:loginURL];
	[loginRequest setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
	[loginRequest setHTTPMethod:@"POST"];
	
	// set request
	queue.request = loginRequest;
	
	return queue;
}

+ (NSString*)ITCSalesPageURL:(NSString*)html {
	NSScanner *scanner = [NSScanner scannerWithString:html];
	
	while (![scanner isAtEnd]) {
		NSString *link = nil;
		NSString *title = nil;
		if ([scanner scanUpToString:@"<td class=\"content\">" intoString:nil]) {
			if ([scanner scanUpToString:@"<a href=\"" intoString:nil]) {
				if ([scanner scanString:@"<a href=\"" intoString:nil]) {
					if ([scanner scanUpToString:@"\">" intoString:&link]) {
						
						if ([scanner scanUpToString:@"<b>" intoString:nil]) {
							if ([scanner scanString:@"<b>" intoString:nil]) {
								if ([scanner scanUpToString:@"</b>" intoString:&title]) {
								}
							}
						}
					}
				}
			}
		}
		if ([link length] && [title length]) {
			NSLog(@"%@, %@", link, title);
			NSRange r = [title rangeOfString:@"Sales and Trends"];
			if (r.location == 0) {
				return [NSString stringWithFormat:@"%@/%@", @"https://itunesconnect.apple.com", link];
			}
			
		}
	}
	return nil;
}

#pragma mark -
#pragma mark SNDownloadQueueDelegate

- (void)doTaskAfterDownloadingData:(NSData*)data {
	DNSLogMethod

	NSString *html = [NSString stringAutoDecodeFromData:data];
	if (html) {
		ITCSalesPage *queue = [ITCSalesPage defaultQueue];
		[[SNDownloadManager sharedInstance] addQueue:queue];
	}
	else {
		// failed error
		showAlertWithMessage(NSLocalizedString(@"Failed to access iTunes connect.", nil));
	}
}

- (void)doTaskAfterFailedDownload:(NSError *)error {
	// failed error
	showAlertWithMessage(NSLocalizedString(@"Failed to access iTunes connect.", nil));
}

@end

//
//  ITCLoginPage.m
//  StoreSales
//
//  Created by sonson on 10/09/09.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ITCLoginPage.h"
#import "ITCLogin.h"
#import "ITCTool.h"
#import "KeychainAccessor.h"
#import "NSDictionary+URLArgments.h"
#import "NSDictionary+HTTP.h"

#import "SNDownloadManager.h"
#import "UICNSString+AutoDecoder.h"

@implementation ITCLoginPage

+ (ITCLoginPage*)defaultQueue {
	DNSLogMethod
	
	for (NSHTTPCookie *cookie in [[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies] reverseObjectEnumerator]) {
		if ([[cookie domain] rangeOfString:@".apple.com"].location != NSNotFound) {
			[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
		}
	}
	
	ITCLoginPage *queue = [[ITCLoginPage alloc] init];
	
	
	NSURL *loginURL = [NSURL URLWithString:@"https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa"];
	NSMutableURLRequest *loginRequest = [NSMutableURLRequest requestWithURL:loginURL];
	[loginRequest setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
	[queue setRequest:loginRequest];
	
	return [queue autorelease];
}

#pragma mark -
#pragma mark SNDownloadQueueDelegate

- (void)doTaskAfterDownloadingData:(NSData*)data {
	DNSLogMethod
	NSString *html = [NSString stringAutoDecodeFromData:data];
	
	
	if (html == nil) {
		// vacant.
		showAlertWithMessage(NSLocalizedString(@"Failed to access iTunes connect.", nil));
		return;
	}
	
	NSScanner *scanner = [NSScanner scannerWithString:html];
	
	NSString *postURL = nil;
	
	[scanner scanUpToString:@"<form name=\"appleConnectForm\" method=\"post\" action=\"" intoString:nil];
	[scanner scanString:@"<form name=\"appleConnectForm\" method=\"post\" action=\"" intoString:nil];
	[scanner scanUpToString:@"\">" intoString:&postURL];

	NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", @"https://itunesconnect.apple.com", postURL];
	DNSLog(@"%@", urlString);
	
	//
	// Obtain username and password
	//
#if TARGET_OS_IPHONE
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
		showAlertWithMessage(NSLocalizedString(@"iTunes connect account info has not been inputed.", nil));
		return;
	}
	NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              username, @"theAccountName",
                              password, @"theAccountPW", 
                              @"0", @"1.Continue.x",
                              @"0", @"1.Continue.y",
                              nil];
    NSString *postDictString = [postDict formatForHTTP];
    NSData *httpBody = [postDictString dataUsingEncoding:NSASCIIStringEncoding];
	NSMutableURLRequest *loginRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [loginRequest setHTTPMethod:@"POST"];
    [loginRequest setHTTPBody:httpBody];
	
	if ([postURL length]) {
		ITCLogin *queue = [[ITCLogin alloc] init];
		[queue setRequest:loginRequest];
		[[SNDownloadManager sharedInstance] addQueue:queue];
		[queue release];
	}
}

- (void)doTaskAfterFailedDownload:(NSError *)error {
	// failed error
	showAlertWithMessage(NSLocalizedString(@"Failed to access iTunes connect.", nil));
}

@end

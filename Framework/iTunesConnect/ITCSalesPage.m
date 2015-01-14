//
//  ITCSalesPage.m
//  StoreSales
//
//  Created by sonson on 10/09/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ITCSalesPage.h"
#import "ITCSalesFaces.h"
#import "SNDownloadManager.h"
#import "NSDictionary+HTTP.h"
#import "ITCTool.h"

@implementation ITCSalesPage

#pragma mark -
#pragma mark Class method for making a new instance

+ (ITCSalesPage*)defaultQueue {
	DNSLogMethod
	ITCSalesPage *queue = [[ITCSalesPage alloc] init];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://reportingitc.apple.com/"]];
	//NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/wo/2.0.9.7.2.9.1.0.0.3"]];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
	[queue setRequest:request];
	return [queue autorelease];
}

+ (ITCSalesPage*)queueWithURLString:(NSString*)urlString {
	DNSLogMethod
	
	ITCSalesPage *queue = [[ITCSalesPage alloc] init];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
	[queue setRequest:request];
	return [queue autorelease];
}

#pragma mark -
#pragma mark instance method

- (NSString*)extractViewStateFromHTML:(NSString*)htmlString {
	NSScanner *scanner = [NSScanner scannerWithString:htmlString];
	[scanner scanUpToString:@"\"javax.faces.ViewState\" value=\"" intoString:nil];
	if (! [scanner scanString:@"\"javax.faces.ViewState\" value=\"" intoString:nil]) {
		return nil;
	}
	NSString *viewState = nil;
	[scanner scanUpToString:@"\"" intoString:&viewState];
	return viewState;
}

- (NSString*)extractScriptIDFromHTML:(NSString*)htmlString {
	NSScanner *scanner = [NSScanner scannerWithString:htmlString];
	[scanner scanUpToString:@"script id=\"defaultVendorPage:" intoString:nil];
	if (! [scanner scanString:@"script id=\"defaultVendorPage:" intoString:nil]) {
		return nil;
	}
	NSString *defaultVendorPage = nil;
	[scanner scanUpToString:@"\"" intoString:&defaultVendorPage];
	return defaultVendorPage;
}

#pragma mark -
#pragma mark SNDownloadQueueDelegate

#define ITTS_VENDOR_DEFAULT_URL @"https://reportingitc.apple.com/vendor_default.faces"

- (void)doTaskAfterDownloadingData:(NSData*)data {
	DNSLogMethod
	NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	DNSLog(@"%@", html);
	
	NSString *defaultVendorPage = [self extractScriptIDFromHTML:html];
	NSString *viewState = [self extractViewStateFromHTML:html];
	
	DNSLog(@"defaultVendorPage=%@", defaultVendorPage);
	DNSLog(@"viewState=%@", viewState);
	
	if (![defaultVendorPage length]|| ![viewState length]) {
		showAlertWithMessage(NSLocalizedString(@"Failed to access iTunes connect.", nil));
		return;
	}
	
	// click though from the dashboard to the sales page
    NSDictionary *reportPostData = [NSDictionary dictionaryWithObjectsAndKeys:
									[defaultVendorPage stringByReplacingOccurrencesOfString:@"_2" withString:@"_0"],	@"AJAXREQUEST",
									viewState,																			@"javax.faces.ViewState",
									defaultVendorPage,																	@"defaultVendorPage",
									[@"defaultVendorPage:" stringByAppendingString:defaultVendorPage],					[@"defaultVendorPage:" stringByAppendingString:defaultVendorPage],
									nil];
	DNSLog(@"%@", reportPostData);
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ITTS_VENDOR_DEFAULT_URL]];
	
	NSString *postDictString = [reportPostData formatForHTTP];
    NSData *httpBody = [postDictString dataUsingEncoding:NSASCIIStringEncoding];
	
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:httpBody];
	
	[NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
	
	ITCSalesFaces *queue = [ITCSalesFaces defaultQueue];
	[[SNDownloadManager sharedInstance] addQueue:queue];
}

- (void)doTaskAfterFailedDownload:(NSError*)error {
	DNSLogMethod
	showAlertWithMessage(NSLocalizedString(@"Failed to access iTunes connect.", nil));
}

@end

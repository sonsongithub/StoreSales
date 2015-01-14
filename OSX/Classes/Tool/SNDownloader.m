//
//  SNDownloader.m
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 sonson. All rights reserved.
//

#import "SNDownloader.h"

NSString *kSNDownloaderCancel = @"kSNDownloaderCancel";

@implementation SNURLConnection

@synthesize delegate;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)newDelegate {
	DNSLogMethod
	self = [super initWithRequest:request delegate:newDelegate];
	self.delegate = newDelegate;
	return self;
}

- (void)dealloc {
	DNSLogMethod
	[self.delegate release];
	[super dealloc];
}

@end

@implementation SNDownloader

@synthesize delegate;
@synthesize connection;
@synthesize savedData;
@synthesize sizeToRecieve;
@synthesize request;
@synthesize httpURLResponse;
@synthesize enableErrorMessage;
@synthesize callback;

#pragma mark Class Method

- (id)initWithDelegate:(id)newDelegate {
	DNSLogMethod
	self = [super init];
	self.delegate = newDelegate;
	enableErrorMessage = YES;
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(cancelViaNSNotificationCenter)
												 name:kSNDownloaderCancel
											   object:self.delegate];
	return self;
}

- (void)cancelViaNSNotificationCenter {
	DNSLogMethod
	[self cancel];
}

- (void)cancel {
	[connection cancel];
}

- (void)startWithRequest:(NSURLRequest*)newRequest {
	DNSLogMethod
	connection = [[SNURLConnection alloc] initWithRequest:newRequest delegate:self];
	[connection release];
	self.request = newRequest;
	self.savedData = [NSMutableData data];
}

#pragma mark Messaging

- (void)displayActionView:(NSString*)message {
	if( !enableErrorMessage )
		return;
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
														message:message
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)
											  otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response {
	DNSLogMethod
	httpURLResponse = [(NSHTTPURLResponse*)response retain];
	NSDictionary *headerDict = [httpURLResponse allHeaderFields];
/*	
	// check URL between request and response 
	if( ![[[response URL] absoluteString] isEqualToString:[[request URL] absoluteString]]) {
		DNSLog(@"Diffrenct URL loaded");
		[connection cancel];
		if( [self.delegate respondsToSelector:@selector(didDifferenctURLLoading)] ) {
			[self.delegate didDifferenctURLLoading];
			[self displayActionView:NSLocalizedString(@"DifferentURLIsLoaded.", nil)];
		}
	}
*/
	// check length between request and response
	NSString* response_length = [headerDict objectForKey:@"Content-Length"];
	if( response_length )
		sizeToRecieve = [response_length intValue];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData*)data lengthReceived:(int)length {
	[savedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
	DNSLogMethod
	DNSLog( @"[SNDownloader] %d/%d byte", [savedData length], sizeToRecieve );
	
	if ([self.delegate respondsToSelector:callback]) {
		[self.delegate performSelector:callback withObject:savedData];
	}
	else if ([self.delegate respondsToSelector:@selector(didFinishLoading:response:)]) {
		[self.delegate didFinishLoading:savedData response:httpURLResponse];
	}
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
	DNSLogMethod
	DNSLog( @"[SNDownloader] Error:%@", [error localizedDescription] );
	if( [self.delegate respondsToSelector:@selector(didFailLoadingWithError:)] ) {
		[self.delegate didFailLoadingWithError:error];
		[self displayActionView:[error localizedDescription]];
	}
}

- (void) dealloc {
	DNSLogMethod
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[httpURLResponse release];
	[delegate release];
	[savedData release];
	[request release];
	[super dealloc];
}

@end

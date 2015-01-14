//
//  ITCDownloadScheduler.m
//  StoreSales
//
//  Created by sonson on 09/11/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ITCDownloadScheduler.h"

// Singleton object
ITCDownloadScheduler *sharedITCDownloadScheduler = nil;

// Time interval definition
#define CHECK_INTERVAL_SECOND	3600		// an hour
#define UPDATE_INTERVAL_SECOND	43200		// an half day, 12 hours

@implementation ITCDownloadScheduler

#pragma mark -
#pragma mark Class method

+ (ITCDownloadScheduler*)sharedInstance {
	if (sharedITCDownloadScheduler == nil) {
		sharedITCDownloadScheduler = [[ITCDownloadScheduler alloc] init];
	}
	return sharedITCDownloadScheduler;
}

#pragma mark -
#pragma mark Instance method

- (BOOL)activate {
	BOOL isActivatedITCDownloadScheduler = [[NSUserDefaults standardUserDefaults] boolForKey:@"IsActivatedITCDownloadScheduler"];
	if (isActivatedITCDownloadScheduler) {
		return YES;
	}
	[self invalidate];
	return NO;
}

- (void)validate {
	DNSLogMethod
	if ([self activate]) {
		isPeriodicalChecked = YES;
		if (taskTimer == nil) {
			taskTimer = [NSTimer scheduledTimerWithTimeInterval:CHECK_INTERVAL_SECOND target:self selector:@selector(doTask:) userInfo:nil repeats:YES];
		}
		if (periodCheckTimer == nil) {
			periodCheckTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_INTERVAL_SECOND target:self selector:@selector(doUpdateTimeToDoTask:) userInfo:nil repeats:YES];
		}
	}
}

- (void)invalidate {
	DNSLogMethod
	if (periodCheckTimer) {
		[periodCheckTimer invalidate];
		periodCheckTimer = nil;
	}
	if (taskTimer) {
		[taskTimer invalidate];
		taskTimer = nil;
	}
}

- (void)doTask:(NSTimer*)timer {
	if (isPeriodicalChecked) {
		DNSLog(@"Missed");
		return;
	}
	NSTimeInterval interval = [NSDate timeIntervalSinceReferenceDate];
	if (interval > periodicalTime) {
		DNSLog(@"Reload");
		isPeriodicalChecked = YES;
		[UIAppDelegate download:self];
	}
}

- (void)doUpdateTimeToDoTask:(NSTimer*)timer {
	DNSLogMethod
	periodicalTime = [NSDate timeIntervalSinceReferenceDate];
	isPeriodicalChecked = NO;
}

#pragma mark -
#pragma mark dealloc

- (id)init {
	if ((self = [super init])) {
		isPeriodicalChecked = YES;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

@end

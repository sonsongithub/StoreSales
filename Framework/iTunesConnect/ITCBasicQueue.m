//
//  ITCBasicQueue.m
//  StoreSales
//
//  Created by sonson on 10/09/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ITCBasicQueue.h"

@implementation ITCBasicQueue

@synthesize dailyName;
@synthesize weeklyName;
@synthesize ajaxName;
@synthesize daySelectName;
@synthesize weekSelectName;

@synthesize dailyValues;
@synthesize weeklyValues;

@synthesize dummyDailyValue;
@synthesize dummyWeeklyValue;

@synthesize viewState;
@synthesize currentViewState;

- (id)initWithITCBasicQueue:(ITCBasicQueue*)queue {
	if ((self = [super init])) {
		self.ajaxName = queue.ajaxName;
		self.viewState = queue.viewState;
		self.dailyName = queue.dailyName;
		self.weeklyName = queue.weeklyName;
		self.daySelectName = queue.daySelectName;
		self.weekSelectName = queue.weekSelectName;
		self.dailyValues = queue.dailyValues;
		self.weeklyValues = queue.weeklyValues;
		
		self.dummyDailyValue = queue.dummyDailyValue;
		self.dummyWeeklyValue = queue.dummyWeeklyValue;
	}
	return self;
}

- (id)initWithAJAXName:(NSString*)_ajaxName
						 dailyName:(NSString*)_dailyName
						weeklyName:(NSString*)_weeklyName
					 daySelectName:(NSString*)_daySelectName
					weekSelectName:(NSString*)_weekSelectName
					   dailyValues:(NSMutableArray*)_dailyValues
					  weeklyValues:(NSMutableArray*)_weeklyValues
						 viewState:(NSString*)_viewState
		dummyDailyValue:(NSString*)_dummyDailyValue 
dummyWeeklyValue:(NSString*)_dummyWeeklyValue
{
	if ((self = [super init])) {
		self.ajaxName = _ajaxName;
		self.viewState = _viewState;
		self.dailyName = _dailyName;
		self.weeklyName = _weeklyName;
		self.daySelectName = _daySelectName;
		self.weekSelectName = _weekSelectName;
		self.dailyValues = _dailyValues;
		self.weeklyValues = _weeklyValues;
		self.dummyWeeklyValue = _dummyWeeklyValue;
		self.dummyDailyValue = _dummyDailyValue;
	}
	return self;
}

- (void)update {
	// this is dummy
}

- (void) dealloc {
	[dailyName release];
	[weeklyName release];
	[ajaxName release];
	[daySelectName release];
	[weekSelectName release];
	
	[dailyValues release];
	[weeklyValues release];
	
	[dummyDailyValue release];
	[dummyWeeklyValue release];
	
	[viewState release];
	[currentViewState release];
	
	[super dealloc];
}


@end

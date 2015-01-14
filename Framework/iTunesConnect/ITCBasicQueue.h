//
//  ITCBasicQueue.h
//  StoreSales
//
//  Created by sonson on 10/09/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNDownloadQueue.h"

#import "NSDictionary+HTTP.h"
#import "NSString+ITC.h"
#import "UICNSString+AutoDecoder.h"
#import "SNDownloadManager.h"

@interface ITCBasicQueue : SNDownloadQueue {
	NSString *dailyName;
	NSString *weeklyName;
	NSString *ajaxName;
	NSString *daySelectName;
	NSString *weekSelectName;
	
	NSMutableArray *dailyValues;
	NSMutableArray *weeklyValues;
	
	NSString *dummyDailyValue;
	NSString *dummyWeeklyValue;
	
	NSString *viewState;
	NSString *currentViewState;
}
@property (nonatomic, retain) NSString* dailyName;
@property (nonatomic, retain) NSString* weeklyName;
@property (nonatomic, retain) NSString* ajaxName;
@property (nonatomic, retain) NSString* daySelectName;
@property (nonatomic, retain) NSString* weekSelectName;

@property (nonatomic, retain) NSMutableArray* dailyValues;
@property (nonatomic, retain) NSMutableArray* weeklyValues;

@property (nonatomic, retain) NSString* dummyDailyValue;
@property (nonatomic, retain) NSString* dummyWeeklyValue;

@property (nonatomic, retain) NSString* viewState;
@property (nonatomic, retain) NSString* currentViewState;

- (id)initWithITCBasicQueue:(ITCBasicQueue*)queue;

- (id)initWithAJAXName:(NSString*)_ajaxName
			 dailyName:(NSString*)_dailyName
			weeklyName:(NSString*)_weeklyName
		 daySelectName:(NSString*)_daySelectName
		weekSelectName:(NSString*)_weekSelectName
		   dailyValues:(NSMutableArray*)_dailyValues
		  weeklyValues:(NSMutableArray*)_weeklyValues
			 viewState:(NSString*)_viewState
	   dummyDailyValue:(NSString*)_dummyDailyValue 
	  dummyWeeklyValue:(NSString*)_dummyWeeklyValue;

- (void)update;
@end

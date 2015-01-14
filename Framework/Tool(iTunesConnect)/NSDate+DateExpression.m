//
//  NSDate+DateExpression.m
//  StoreSales
//
//  Created by sonson on 09/02/21.
//  Copyright 2009 sonson. All rights reserved.
//

#import "NSDate+DateExpression.h"

NSDateFormatter *DateExpressionMMddyyyy = nil;
NSDateFormatter *DateExpressionyyyyMMdd = nil;

@implementation NSDate(DateExpression)

+ (void)initialize {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	if (DateExpressionMMddyyyy == nil) {
		DateExpressionMMddyyyy = [[NSDateFormatter alloc] init];
		[DateExpressionMMddyyyy setTimeStyle:NSDateFormatterFullStyle];
		[DateExpressionMMddyyyy setDateFormat:@"MM/dd/yyyy"];
	}
	if (DateExpressionyyyyMMdd == nil) {
		DateExpressionyyyyMMdd = [[NSDateFormatter alloc] init];
		[DateExpressionyyyyMMdd setTimeStyle:NSDateFormatterFullStyle];
		[DateExpressionyyyyMMdd setDateFormat:@"yyyyMMdd"];
	}
	[pool release];
}

+ (NSDate*)dateFromDateExpression:(NSString*)str {
	if (str == nil) {
		return nil;
	}
	NSDate *date = nil;
	date = [NSDate dateFromDateExpressionMMddyyyy:str];
	if (date)
		return date;
	
	date = [NSDate dateFromDateExpressionyyyyMMdd:str];
	return date;
}

+ (NSDate*)dateFromDateExpressionMMddyyyy:(NSString*)str {
	if (str == nil) {
		return nil;
	}
	return [DateExpressionMMddyyyy dateFromString:str];
}

+ (NSDate*)dateFromDateExpressionyyyyMMdd:(NSString*)str {
	if (str == nil) {
		return nil;
	}
	return [DateExpressionyyyyMMdd dateFromString:str];
}

@end

//
//  NSDate+DateExpression.h
//  StoreSales
//
//  Created by sonson on 09/02/21.
//  Copyright 2009 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate(DateExpression)
+ (NSDate*)dateFromDateExpression:(NSString*)str;
+ (NSDate*)dateFromDateExpressionMMddyyyy:(NSString*)str;
+ (NSDate*)dateFromDateExpressionyyyyMMdd:(NSString*)str;
@end

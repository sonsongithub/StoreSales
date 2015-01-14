//
//  NSString+substringFromSuffixToPrefix.h
//  StoreSales
//
//  Created by sonson on 10/09/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(substringFromSuffixToPrefix)
- (NSString*)substringFromSuffix:(NSString*)suffix ToPrefix:(NSString*)prefix;
@end

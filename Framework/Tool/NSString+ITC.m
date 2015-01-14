//
//  NSString+ITC.m
//  StoreSales
//
//  Created by sonson on 10/09/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+ITC.h"
#import "NSString+substringFromSuffixToPrefix.h"

@implementation NSString(ITC)

- (NSString*)extractViewState {
	return [self substringFromSuffix:@"\"javax.faces.ViewState\" value=\"" ToPrefix:@"\""];
}

@end

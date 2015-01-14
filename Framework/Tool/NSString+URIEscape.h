//
//  NSString+URIEscape.h
//  StoreSales
//
//  Created by sonson on 09/04/05.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString(URIEscape)
- (NSString*)stringByAddingPercentEscapesAllSingleByteCharsUsingEncoding:(NSStringEncoding)encodeing;
@end

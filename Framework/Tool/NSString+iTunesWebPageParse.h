//
//  NSString+iTunesWebPageParse.h
//  StoreSales
//
//  Created by sonson on 11/05/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(iTunesWebPageParse)

- (NSString*)extractLeftStack;
- (NSString*)extractiTunesWebPageImageURL;
- (NSString*)extractArtworkDIV;

@end

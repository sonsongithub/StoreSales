//
//  UIImage+ClippedIcon.h
//  StoreSales
//
//  Created by sonson on 09/02/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage(ClippedIcon)
- (void)drawClippedIconInRect:(CGRect)rect;
- (void)drawClippedAndShadowedIconInRect:(CGRect)rect;
@end

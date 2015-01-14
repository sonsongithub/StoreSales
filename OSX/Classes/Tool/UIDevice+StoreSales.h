//
//  UIDevice+StoreSales.h
//  StoreSales
//
//  Created by sonson on 09/09/27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIDevice(StoreSales)
+ (NSString*)descriptionOfOrientation:(UIDeviceOrientation)orientation;
- (NSString*)descriptionOfCurrentOrientation;
@end

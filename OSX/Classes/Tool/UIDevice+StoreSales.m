//
//  UIDevice+StoreSales.m
//  StoreSales
//
//  Created by sonson on 09/09/27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UIDevice+StoreSales.h"

@implementation UIDevice(StoreSales)

+ (NSString*)descriptionOfOrientation:(UIDeviceOrientation)orientation {
	switch (orientation) {
		case UIDeviceOrientationUnknown:
			return @"UIDeviceOrientationUnknown";
		case UIDeviceOrientationPortrait:
			return @"UIDeviceOrientationPortrait";
		case UIDeviceOrientationPortraitUpsideDown:
			return @"UIDeviceOrientationPortraitUpsideDown";
		case UIDeviceOrientationLandscapeLeft:
			return @"UIDeviceOrientationLandscapeLeft";
		case UIDeviceOrientationLandscapeRight:
			return @"UIDeviceOrientationLandscapeRight";
		case UIDeviceOrientationFaceUp:
			return @"UIDeviceOrientationFaceUp";
		case UIDeviceOrientationFaceDown:
			return @"UIDeviceOrientationFaceDown";
		default:
			return @"Unknown";
	}
}

- (NSString*)descriptionOfCurrentOrientation {
	return [UIDevice descriptionOfOrientation:[UIDevice currentDevice].orientation];
}

@end

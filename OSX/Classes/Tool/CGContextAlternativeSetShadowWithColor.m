//
//  CGContextAlternativeSetShadowWithColor.m
//  StoreSales
//
//  Created by sonson on 10/06/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CGContextAlternativeSetShadowWithColor.h"

static BOOL IS_SHADOW_DIRECTION_3_2_LATER = YES;

void CGContextCheckShadowDirection() {
	IS_SHADOW_DIRECTION_3_2_LATER = (NSClassFromString(@"ADBannerView") != nil);
}

void CGContextAlternativeSetShadowWithColor(CGContextRef context, CGSize offset, CGFloat blur, CGColorRef color) {
	if (IS_SHADOW_DIRECTION_3_2_LATER) {
		CGContextSetShadowWithColor(context, CGSizeMake(offset.width, offset.height), blur, color);
	}
	else {
		CGContextSetShadowWithColor(context, CGSizeMake(offset.width, -offset.height), blur, color);
	}
}
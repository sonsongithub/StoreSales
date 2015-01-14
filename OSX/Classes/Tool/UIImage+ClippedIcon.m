//
//  UIImage+ClippedIcon.m
//  StoreSales
//
//  Created by sonson on 09/02/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UIImage+ClippedIcon.h"

@implementation UIImage(ClippedIcon)

- (void)iconClipIconRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	// outline 
	CGFloat minx = CGRectGetMinX( rect ), midx = CGRectGetMidX( rect ), maxx = CGRectGetMaxX( rect );
	CGFloat miny = CGRectGetMinY( rect ), midy = CGRectGetMidY( rect ), maxy = CGRectGetMaxY( rect );
	
	// radius is 12 when width = 59
	float radius = rect.size.width / 5;
	
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	CGContextClosePath(context);
	CGContextClip(context);
}

- (void)drawIconShadow:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	// outline 
	CGFloat minx = CGRectGetMinX( rect ), midx = CGRectGetMidX( rect ), maxx = CGRectGetMaxX( rect );
	CGFloat miny = CGRectGetMinY( rect ), midy = CGRectGetMidY( rect ), maxy = CGRectGetMaxY( rect );
	
	// radius is 12 when width = 59
	float radius = rect.size.width / 5;
	
	// offset 3 = 59
	float y_offset = -rect.size.width * 1.0f / 59.0f;
	
	// spraed 2 = 59
	float spread = rect.size.width * 3.0f / 59.0f;
	
	CGContextSaveGState(context);
	CGContextAlternativeSetShadowWithColor(context, CGSizeMake(0, y_offset), spread, [UIColor blackColor].CGColor);
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	CGContextClosePath(context);
	CGContextFillPath(context);
	CGContextRestoreGState(context);
}

- (void)drawClippedIconInRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	[self iconClipIconRect:rect];
	[self drawInRect:rect];
	CGContextRestoreGState(context);
}

- (void)drawClippedAndShadowedIconInRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	[self drawIconShadow:rect];
	[self iconClipIconRect:rect];
	[self drawInRect:rect];
	CGContextRestoreGState(context);
}

@end

//
//  Quartz+Tool.m
//  StoreSales
//
//  Created by sonson on 09/10/18.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Quartz+Tool.h"


void iconClipIconRect(CGContextRef context, NSRect rect) {
	// outline 
	CGFloat minx = NSMinX( rect ), midx = NSMidX( rect ), maxx = NSMaxX( rect );
	CGFloat miny = NSMinY( rect ), midy = NSMidY( rect ), maxy = NSMaxY( rect );
	
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

void drawIconShadow(CGContextRef context, NSRect rect) {
	// outline 
	CGFloat minx = NSMinX( rect ), midx = NSMidX( rect ), maxx = NSMaxX( rect );
	CGFloat miny = NSMinY( rect ), midy = NSMidY( rect ), maxy = NSMaxY( rect );
	
	// radius is 12 when width = 59
	float radius = rect.size.width / 5;
	
	// offset 3 = 59
	float y_offset = -rect.size.width * 1.0f / 59.0f;
	
	// spraed 2 = 59
	// float spread = rect.size.width * 3.0f / 59.0f;
	
	
	float           myColorValues[] = {0, 0, 0, .6};
    CGColorRef      myColor;
    CGColorSpaceRef myColorSpace;
	
	myColorSpace = CGColorSpaceCreateDeviceRGB();
	myColor = CGColorCreate (myColorSpace, myColorValues);
	
	CGContextSaveGState(context);
    CGContextSetShadowWithColor (context,  CGSizeMake(0, y_offset), 5, myColor);
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	CGContextClosePath(context);
	CGContextFillPath(context);
	CGContextRestoreGState(context);
}
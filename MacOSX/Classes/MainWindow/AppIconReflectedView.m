//
//  AppIconReflectedView.m
//  StoreSales
//
//  Created by sonson on 09/10/18.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppIconReflectedView.h"
#import "Quartz+Tool.h"

CGGradientRef sharedReflectedGradient = NULL;

@implementation AppIconReflectedView

@dynamic image;

#pragma mark -
#pragma mark Class method

+ (void)initialize {
	if (sharedReflectedGradient == NULL) {
		CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
		CGFloat colors[] = {
			236.0 / 255.0, 236.0 / 255.0, 236.0 / 255.0, 1,
			255.0 / 255.0, 255.0 / 255.0, 255.0 / 255.0, 0.5
		};
		sharedReflectedGradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
	}
}

#pragma mark -
#pragma mark Accessor

- (void)setImage:(NSImage *)newValue {
	image = [newValue copy];
	[self setNeedsDisplay:NO];
}

#pragma mark -
#pragma mark Instance method

- (id)initWithAppIconImage:(NSImage*)newImage {
    if ((self = [super initWithFrame:NSMakeRect(0, 0, [newImage size].width, [newImage size].height * 2)])) {
        // Initialization code here.
		image = [newImage copy];
    }
    return self;
}

#pragma mark -
#pragma mark Override

- (void)drawRect:(NSRect)dirtyRect {
	if (image != nil) {
		CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
		
		NSSize iconsize = [image size];
		NSRect imageFrame = [self bounds];
		
		imageFrame.origin.x = 0;
		imageFrame.origin.y = 0;
		imageFrame.size = iconsize;
		
		// Draw normal icon
		[image setFlipped:NO];
		CGContextSaveGState(context);
		imageFrame.origin.y = [self bounds].size.height - iconsize.height;
		iconClipIconRect(context, imageFrame);
		[image drawInRect:imageFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		CGContextRestoreGState(context);
		[image setFlipped:YES];
		
		// For clipping
		CGContextSaveGState(context);

		// Set rendering frame for reflective icon
		imageFrame.origin.y = [self bounds].size.height - iconsize.height - iconsize.height;
		
		// Clipping
		iconClipIconRect(context, imageFrame);
		
		// Draw reflected icon
		[image drawInRect:imageFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];

		// Draw reflected gradient back ground color
		CGPoint start = CGPointMake( 0, imageFrame.origin.y + imageFrame.size.height * 0.4);
		CGPoint end = CGPointMake( 0, imageFrame.origin.y + imageFrame.size.height );
		CGContextDrawLinearGradient(context, sharedReflectedGradient, start, end, kCGGradientDrawsAfterEndLocation | kCGGradientDrawsBeforeStartLocation);
		
		// Clipping
		CGContextRestoreGState(context);
    }
	[super drawRect:dirtyRect];
}

#pragma mark -
#pragma mark dealloc

- (void) dealloc {
	[image release];
	[super dealloc];
}

@end

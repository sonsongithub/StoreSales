//
//  AppIconView.m
//  StoreSales
//
//  Created by sonson on 09/10/17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppIconView.h"
#import "Quartz+Tool.h"

@implementation AppIconView

@dynamic image;

#pragma mark -
#pragma mark Accessor

- (void)setImage:(NSImage *)newValue {
	image = [newValue copy];
	[self setNeedsDisplay:NO];
}

#pragma mark -
#pragma mark Instance method

- (id)initWithAppIconImage:(NSImage*)newImage {
    if ((self = [super initWithFrame:NSMakeRect(0, 0, [newImage size].width, [newImage size].height)])) {
        // Initialization code here.
		image = [newImage copy];
    }
    return self;
}

#pragma mark -
#pragma mark Override

- (void)drawRect:(NSRect)dirtyRect {
	if (image != nil) {
		// Calculate icon size
		// Reduce icon size to make a space to be rendered with icon's shadow.
		float ratio = 0.8;
		NSSize iconsize = NSMakeSize([self bounds].size.width * ratio, [self bounds].size.height * ratio);

		NSRect iconFrame = [self bounds];
		iconFrame.origin.x += iconFrame.size.width * (1 - ratio) * 0.5;
		iconFrame.origin.y += iconFrame.size.height * (1 - ratio) * 0.5;
		iconFrame.size = iconsize;
		
		// Get current graphics context
		CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
		
		// Draw icon shadow
		drawIconShadow(context, iconFrame);
		
		// Set clipping
		CGContextSaveGState(context);
		iconClipIconRect(context, iconFrame);
		
		// Draw icon
		[image drawInRect:iconFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		
		// Restore previous clipping status
		CGContextRestoreGState(context);
    }
	[super drawRect:dirtyRect];
}

- (void) dealloc {
	[image release];
	[super dealloc];
}


@end

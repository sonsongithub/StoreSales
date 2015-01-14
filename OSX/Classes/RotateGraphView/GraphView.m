//
//  GraphView.m
//  StoreSales
//
//  Created by sonson on 09/03/08.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"

CGGradientRef GraphViewBackgroundGradient = NULL;

@implementation GraphView

+ (void)initialize {
	// setup gradient color
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	if (GraphViewBackgroundGradient == NULL) {
		CGFloat colors[] = {
			0.0f / 255.0, 0.0f / 255.0, 0.0f / 255.0, 1.00,
			100.0f / 255.0, 100.0f / 255.0, 115.0f / 255.0, 1.00
		};
		GraphViewBackgroundGradient = CGGradientCreateWithColorComponents( rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4) );
	}
	CGColorSpaceRelease(rgb);
}

#pragma mark -
#pragma mark Gesture delegate method

- (void)swipedUp {
	DNSLogMethod
}

- (void)swipedDown {
	DNSLogMethod
}

#pragma mark -
#pragma mark Draw fade in/out

- (void)startAnimationTimer {
	// dummy
}

- (void)startToAppear {
	self.alpha = 0.0;
	[UIView beginAnimations:@"a" context:nil];
	[UIView setAnimationDuration:0.5];
	self.alpha = 1.0;
	[UIView commitAnimations];
}

- (void)startToDisappear {
	[UIView beginAnimations:@"a" context:nil];
	[UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	self.alpha = 0.0;
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	DNSLogMethod
	UITouch *touch = [touches anyObject];
	if (touch.tapCount == 2) {
		[self swipedUp];
	}
#ifdef _USE_GESTURE
	UITouch *touch = [touches anyObject];
	if ([touch tapCount] == 1) {
		gestureStartTimeStamp = touch.timestamp;
		gestureStartPoint = [touch locationInView:self];
	}
#endif
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	DNSLogMethod
#ifdef _USE_GESTURE
	UITouch *touch = [touches anyObject];
	CGPoint gestureEndPoint = [touch locationInView:self];
	NSTimeInterval gestureEnd = touch.timestamp;
	
	if (gestureStartTimeStamp > 0) {
		if (gestureEnd - gestureStartTimeStamp > 0.2) {
			gestureStartTimeStamp = 0;
		}
		else {
			if (fabs(gestureEndPoint.x - gestureStartPoint.x) < 10 && fabs(gestureEndPoint.y - gestureStartPoint.y) > 20) {
				
				if (gestureEndPoint.y - gestureStartPoint.y < 0) {
					[self swipedUp];
				}
				else {
					[self swipedDown];
				}
				gestureStartTimeStamp = 0;
			}
		}
	}
#endif
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	DNSLogMethod
#ifdef _USE_GESTURE
	gestureStartTimeStamp = 0;
#endif
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	DNSLogMethod
#ifdef _USE_GESTURE
	gestureStartTimeStamp = 0;
#endif
}

#pragma mark -
#pragma mark Overridde

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	DNSLogMethod
    // Draw shading background
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGContextClipToRect(context, rect);
	CGPoint start = CGPointMake(0, 0);
	CGPoint end = CGPointMake(0, rect.size.height);
	CGContextDrawLinearGradient(context, GraphViewBackgroundGradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	CGContextRestoreGState(context);
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
    [super dealloc];
}

@end

//
//  CircleGraphView.m
//  StoreSales
//
//  Created by sonson on 09/03/15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CircleGraphView.h"

@implementation CircleGraphView

@synthesize animationTimer;

- (void)drawGraphRect:(CGRect)rect {
}

- (void)drawAnimationWithClippingRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGPoint p1, p2, center;
	p1.x = RADIUS_ROTATE_CIRCLE_COVER * cos(-M_PI/2.0) + CENTER_X_ROTATE_CIRCLE_GRAPH;
	p1.y = RADIUS_ROTATE_CIRCLE_COVER * sin(-M_PI/2.0) + CENTER_Y_ROTATE_CIRCLE_GRAPH;
	center.x = CENTER_X_ROTATE_CIRCLE_GRAPH;
	center.y = CENTER_Y_ROTATE_CIRCLE_GRAPH;
	p2.x = RADIUS_ROTATE_CIRCLE_COVER * cos(deg) + CENTER_X_ROTATE_CIRCLE_GRAPH;
	p2.y = RADIUS_ROTATE_CIRCLE_COVER * sin(deg) + CENTER_Y_ROTATE_CIRCLE_GRAPH;
	
	CGContextMoveToPoint(context, center.x, center.y);
	CGContextAddLineToPoint(context, p1.x, p1.y);
	CGContextAddArc(context, CENTER_X_ROTATE_CIRCLE_GRAPH, CENTER_Y_ROTATE_CIRCLE_GRAPH, RADIUS_ROTATE_CIRCLE_COVER, M_PI/2.0*3.0, deg, false);
	CGContextAddLineToPoint(context, p2.x, p2.y);
	CGContextClosePath(context);
	CGContextClip(context);
	[self drawGraphRect:rect];
	CGContextRestoreGState(context);
}

- (void)redraw:(NSTimer*)theTimer {
	deg += 0.4;
	if (deg > M_PI/2.0*3.0) {
		[self.animationTimer invalidate];
		self.animationTimer = nil;
		[self didFinishAnimation];
	}
	[self setNeedsDisplay];
}

- (void)didFinishAnimation {
	BOOL IsNotFirstUseOfCircleChart = [[NSUserDefaults standardUserDefaults] boolForKey:@"IsNotFirstUseOfCircleChart"];
	if (!IsNotFirstUseOfCircleChart) {
		UIAlertView *view = [[UIAlertView alloc] initWithTitle:nil
													   message:NSLocalizedString(@"You can change the graph with double tap.", nil)
													  delegate:nil
											 cancelButtonTitle:nil
											 otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
		[view show];
		[view release];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IsNotFirstUseOfCircleChart"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void)startAnimationTimer {
	DNSLogMethod
	deg = -M_PI/2.0;
	self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(redraw:) userInfo:nil repeats:YES];
}

- (void)drawNoDataMessageRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.5);
	CGContextFillEllipseInRect(context, CGRectMake(CENTER_X_ROTATE_CIRCLE_GRAPH-RADIUS_ROTATE_CIRCLE_GRAPH, CENTER_Y_ROTATE_CIRCLE_GRAPH-RADIUS_ROTATE_CIRCLE_GRAPH, 2 * RADIUS_ROTATE_CIRCLE_GRAPH, 2 * RADIUS_ROTATE_CIRCLE_GRAPH));
	
	CGContextSaveGState(context);
	CGContextAlternativeSetShadowWithColor(context, CGSizeMake(0, 0), 2.0, [UIColor blackColor].CGColor);
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	UIFont *font = [UIFont boldSystemFontOfSize:20];
	NSString *text = NSLocalizedString(@"no data", nil);
	CGSize size = [text sizeWithFont:font];
	int x = CENTER_X_ROTATE_CIRCLE_GRAPH - size.width/2;
	int y = CENTER_Y_ROTATE_CIRCLE_GRAPH - size.height/2;
	[text drawAtPoint:CGPointMake(x, y) withFont:font];
	CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
}

- (void)dealloc {
	[animationTimer release];
    [super dealloc];
}


@end

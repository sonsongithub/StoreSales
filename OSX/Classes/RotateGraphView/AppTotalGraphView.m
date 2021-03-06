//
//  AppTotalGraphView.m
//  StoreSales
//
//  Created by sonson on 09/03/08.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppTotalGraphView.h"
#import "ApplicationSales.h"
#import "ApplicationInfo.h"
#import "AppTotalInfoCell.h"
#import "UIImage+ClippedIcon.h"


@implementation AppTotalGraphView

@synthesize cells;
@synthesize tableViewController;
@synthesize graphTitle;
@synthesize graphTotalText;

#pragma mark -
#pragma mark Gesture delegate method

- (void)swipedUp {
	DNSLogMethod
	[tableViewController toggleButtonbar:NO];
	self.cells = self.tableViewController.cells;
	[self startAnimationTimer];
}

- (void)swipedDown {
	DNSLogMethod
	[tableViewController toggleButtonbar:YES];
	self.cells = self.tableViewController.cells;
	[self startAnimationTimer];
}

#pragma mark -
#pragma mark Drawing

- (void)drawGraphText:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGContextAlternativeSetShadowWithColor(context, CGSizeMake(0, 0), 2.0, [UIColor blackColor].CGColor);
	UIFont *font1 = [UIFont boldSystemFontOfSize:20];
	UIFont *font2 = [UIFont boldSystemFontOfSize:12];
	[self.graphTitle drawAtPoint:CGPointMake(10, 240) withFont:font1];
	[self.graphTotalText drawAtPoint:CGPointMake(10, 270) withFont:font2];
	CGContextRestoreGState(context);
}

- (void)drawGraphRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGContextAlternativeSetShadowWithColor(context, CGSizeMake(0, 0), 3.0, [UIColor blackColor].CGColor);
	float ratio = 0.0;
	float startDeg = 0;
	float endDeg = 0;
	
	for (ApplicationSales *sales in [cells reverseObjectEnumerator]) {
		startDeg = ratio * M_PI * 2.0 - M_PI / 2;
		UIColor *fillColor = nil;
		endDeg = startDeg - sales.ratio * M_PI * 2.0;
		ratio -= sales.ratio;
		fillColor = sales.info.color;
		DNSLog(@"Color - %@", fillColor);
		if (sales.ratio > 0) {
			[fillColor setFill];
			CGContextMoveToPoint(context, CENTER_X_ROTATE_CIRCLE_GRAPH, CENTER_Y_ROTATE_CIRCLE_GRAPH);
			CGContextAddArc(context, CENTER_X_ROTATE_CIRCLE_GRAPH, CENTER_Y_ROTATE_CIRCLE_GRAPH, RADIUS_ROTATE_CIRCLE_GRAPH, endDeg, startDeg, false);
			CGContextAddLineToPoint(context, CENTER_X_ROTATE_CIRCLE_GRAPH, CENTER_Y_ROTATE_CIRCLE_GRAPH);
			CGContextFillPath(context);
		}
	}
	CGContextRestoreGState(context);
}

- (void)drawIconInGraphRect:(CGRect)rect {
	float ratio = 0.0;
	float startDeg = 0;
	float endDeg = 0;
	for (ApplicationSales *sales in [cells reverseObjectEnumerator]) {
		startDeg = ratio * M_PI * 2.0 - M_PI / 2;
		endDeg = startDeg - sales.ratio * M_PI * 2.0;
		ratio -= sales.ratio;
		double drawDeg = (startDeg + endDeg) / 2;
		CGRect frame;
		frame.origin.x = RADIUS_ROTATE_CIRCLE_ICON * cos(drawDeg) + CENTER_X_ROTATE_CIRCLE_GRAPH - ICON_WIDTH_ROTATE_CIRCLE_GRAPH/2;
		frame.origin.y = RADIUS_ROTATE_CIRCLE_ICON * sin(drawDeg) + CENTER_Y_ROTATE_CIRCLE_GRAPH - ICON_HEIGHT_ROTATE_CIRCLE_GRAPH/2;
		frame.size.width = ICON_WIDTH_ROTATE_CIRCLE_GRAPH;
		frame.size.height = ICON_HEIGHT_ROTATE_CIRCLE_GRAPH;
		if (sales.ratio > 0) {
			[sales.info.icon drawClippedAndShadowedIconInRect:frame];
		}
	}
}

- (void)drawDescriptionInGraphRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	float ratio = 0.0;
	float startDeg = 0;
	float endDeg = 0;
	UIFont *font = [UIFont boldSystemFontOfSize:12];
	for (ApplicationSales *sales in [cells reverseObjectEnumerator]) {
		startDeg = ratio * M_PI * 2.0 - M_PI / 2;
		//UIColor *fillColor = nil;
		endDeg = startDeg - sales.ratio * M_PI * 2.0;
		ratio -= sales.ratio;
		double drawDeg = (startDeg + endDeg) / 2;
		CGPoint p1, p2, p3;
		p1.x = RADIUS_ROTATE_CIRCLE_ICON * cos(drawDeg) + CENTER_X_ROTATE_CIRCLE_GRAPH;
		p1.y = RADIUS_ROTATE_CIRCLE_ICON * sin(drawDeg) + CENTER_Y_ROTATE_CIRCLE_GRAPH;
		p2.x = RADIUS_ROTATE_CIRCLE_GRAPH_LINE * cos(drawDeg) + CENTER_X_ROTATE_CIRCLE_GRAPH;
		p2.y = RADIUS_ROTATE_CIRCLE_GRAPH_LINE * sin(drawDeg) + CENTER_Y_ROTATE_CIRCLE_GRAPH;
		p3.x = RADIUS_ROTATE_CIRCLE_GRAPH_TEXT * cos(drawDeg) + CENTER_X_ROTATE_CIRCLE_GRAPH;
		p3.y = RADIUS_ROTATE_CIRCLE_GRAPH_TEXT * sin(drawDeg) + CENTER_Y_ROTATE_CIRCLE_GRAPH;
		if (sales.ratio > 0) {
		if (sales.ratio < 0.06) {
			CGContextSetRGBStrokeColor(context, 255/255.0f, 125538/255.0f, 255/255.0f, 1.f);
			CGContextSetLineWidth(context, 2.0);
			CGContextMoveToPoint(context, p1.x, p1.y);
			CGContextAddLineToPoint(context, p2.x, p2.y);
			CGContextStrokePath(context);
			CGContextSetRGBFillColor(context, 255/255.0f, 125538/255.0f, 255/255.0f, 1.f);
			NSString *text = [NSString stringWithFormat:@"%3.1f%%", sales.ratio*100];
			CGSize size = [text sizeWithFont:font];
			p3.x = p3.x - size.width / 2;
			p3.y = p3.y - size.height / 2;
			CGRect descriptionRect;
			descriptionRect.origin = p3;
			descriptionRect.size = size;
			[text drawInRect:descriptionRect withFont:font];
		}
		else {
			CGContextSetRGBFillColor(context, 255/255.0f, 125538/255.0f, 255/255.0f, 1.f);
			NSString *text = [NSString stringWithFormat:@"%3.1f%%", sales.ratio*100];
			CGSize size = [text sizeWithFont:font];
			p1.x = p1.x - size.width / 2;
			p1.y = p1.y - size.height / 2 + 20;
			CGRect descriptionRect;
			descriptionRect.origin = p1;
			descriptionRect.size = size;
			[text drawInRect:descriptionRect withFont:font];
		}
		}
	}
}

#pragma mark -
#pragma mark Override

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		deg = -M_PI/2.0;
		self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	if ([cells count] ) {
		if (deg < M_PI/2.0*3.0 && self.animationTimer != nil) {
			[self drawAnimationWithClippingRect:rect];
		}
		else {
			//
			self.graphTitle = [self.tableViewController graphTitle];
			self.graphTotalText = [self.tableViewController graphTotalText];
			
			[self drawGraphRect:rect];
			[self drawDescriptionInGraphRect:rect];
			[self drawIconInGraphRect:rect];
			[self drawGraphText:rect];
		}
	}
	else {
		[self drawNoDataMessageRect:rect];
	}
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[graphTitle release];
	[graphTotalText release];
	[cells release];
	[tableViewController release];
    [super dealloc];
}

@end

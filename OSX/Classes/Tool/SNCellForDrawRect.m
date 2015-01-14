//
//  SNTableViewCellDrawRect.m
//  2tch
//
//  Created by sonson on 08/10/24.
//  Copyright 2008 sonson. All rights reserved.
//

#import "SNCellForDrawRect.h"

CGGradientRef gradient = NULL;

@implementation SNCellForDrawRect

@synthesize originalHighlightedFlag;
@dynamic canSelect;

#pragma mark -
#pragma mark Class method

+ (void)initialize {
	DNSLogMethod
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	CGFloat colors[] = {
		70.0f / 255.0, 146.0f / 255.0, 240.0f / 255.0, 1.00,
		23.0f / 255.0, 84.0f / 255.0, 205.0f / 255.0, 1.00
		//		43.0f / 255.0, 104.0f / 255.0, 225.0f / 255.0, 1.00
	};
	gradient = CGGradientCreateWithColorComponents( rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4) );
	CGColorSpaceRelease(rgb);
}

#pragma mark -
#pragma mark Accessor

- (void)setCanSelect:(BOOL)newValue {
	canSelect = newValue;
	if (canSelect)
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	else
		self.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark -
#pragma mark Instance method

- (void)drawBackground:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBStrokeColor(context, 204.0f/255.0f, 204.0f/255.0f, 204.0f/255.0f, 1.0);
	CGContextSetLineWidth(context, 1.0);
	CGContextMoveToPoint(context, 0, rect.size.height);
	CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
	CGContextStrokePath(context);
}

- (void)drawBackgroundWithGradient:(CGRect)rect {
	DNSLogMethod
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBStrokeColor(context, 204.0f/255.0f, 204.0f/255.0f, 204.0f/255.0f, 1.0);
	CGContextSetLineWidth(context, 1.0);
	CGContextMoveToPoint(context, 0, rect.size.height);
	CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
	CGContextStrokePath(context);
	
	CGContextSaveGState(context);
	CGContextClipToRect(context, rect);
	CGPoint start = CGPointMake(0, 0);
	CGPoint end = CGPointMake(0, rect.size.height);
	CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	CGContextRestoreGState(context);
}

#pragma mark -
#pragma mark Override

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    return self;
}

#pragma mark -
#pragma mark UITableViewCell method

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	if (canSelect)
		originalHighlightedFlag = highlighted;
	[self setNeedsDisplay];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark Override

- (void)drawRect:(CGRect)rect {
	if (self.originalHighlightedFlag) {
		[self drawBackgroundWithGradient:rect];
	}
	else {
		[self drawBackground:rect];
	}
}

- (void) layoutSubviews {
	[super layoutSubviews];
	[self setNeedsDisplay];
}

- (void)dealloc {
    [super dealloc];
}

@end

//
//  AppInfoCell.m
//  StoreSales
//
//  Created by sonson on 09/02/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppInfoCell.h"
#import "ApplicationSales.h"
#import "ApplicationInfo.h"
#import "UIImage+ClippedIcon.h"

#define GRAPH_WIDTH 180

@implementation AppInfoCell

@synthesize sales;
@synthesize orderType;

- (void)drawItemRect:(CGRect)rect {
	DNSLogMethod
	[self drawAsTitle:sales.info.name rect:rect];
	[self drawGraphRatio:sales.ratio rect:rect orderType:orderType];
	[self drawAsValue:sales.valueString rect:(CGRect)rect];
	[sales.info.icon drawClippedAndShadowedIconInRect:CGRectMake(11, 7, 53, 53)];
	if (sales.info.parentIdentifierString)
		[[UIImage imageNamed:@"coins.png"] drawAtPoint:CGPointMake(37, 43)];
}

#pragma mark -
#pragma mark Override

// draw
- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	if (self.originalHighlightedFlag)
		[self drawItemRect:rect];
	else
		[self drawItemRect:rect];
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[sales release];
    [super dealloc];
}

@end

//
//  CountryCell.m
//  StoreSales
//
//  Created by sonson on 09/03/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CountryCell.h"
#import "SNCellForDrawRect.h"

@implementation CountryCell

@synthesize sales;
@synthesize orderType;

- (void)drawFlagRect:(CGRect)rect {
	float icon_area_width = 80;
	float x = (int)(icon_area_width - sales.info.flagImage.size.width) / 2;
	float y = (int)(rect.size.height - sales.info.flagImage.size.height) / 2;
	[sales.info.flagImage drawAtPoint:CGPointMake(x, y)];
}

- (void)drawItemRect:(CGRect)rect {
	[self drawAsTitle:sales.info.name rect:rect];
	[self drawGraphRatio:sales.ratio rect:rect orderType:orderType];
	[self drawAsValue:sales.valueString rect:(CGRect)rect];
}

#pragma mark -
#pragma mark Override

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[self drawItemRect:rect];
	[self drawFlagRect:rect];
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[sales release];
	[super dealloc];
}

@end

//
//  Tile.m
//  StoreSales
//
//  Created by sonson on 09/03/27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Tile.h"

@implementation Tile

@synthesize indexString;
@synthesize tileNumberString;
@synthesize limitTilesX;
@synthesize limitTilesY;

#pragma mark -
#pragma mark Original method

- (id)initWithFrame:(CGRect)frame titleNumberX:(int)numX totalTilesX:(int)totalX titleNumberY:(int)numY totalTilesY:(int)totalY {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		indexX = -1;
		tileNumberX = numX;
		totalTilesX = totalX;
		
		indexY = -1;
		tileNumberY = numY;
		totalTilesY = totalY;
		
		limitTilesX = 2147483647;
		limitTilesY = 2147483647;
		
		float total = totalX * totalY;
		float num = numX + totalX * numY;
		
		float hue = 1.0 / total * (num);
		self.backgroundColor = [UIColor clearColor];
		backColor = [[UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1] retain];
    }
    return self;
}

- (void)resetTileInfo {
	indexX = -1;
	indexY = -1;
	limitTilesX = 2147483647;
	limitTilesY = 2147483647;
}

#pragma mark -
#pragma mark Update Tile Number X,Y

- (void)setCurrentIndexX:(int)currentCenterIndexX indexY:(int)currentCenterIndexY {
	//	DNSLogMethod
	// ((currentCenterIndex + offset1) / 5) * 5 + offset2
	// offset1 = totalTiles / 2 + 1 - (tileNumber + 1);
	// offset2 = tileNumber
	
	int offsetX1 = totalTilesX / 2 + 1 - (tileNumberX + 1);
	int offsetX2 = tileNumberX;
	int newIndexX = ((currentCenterIndexX + offsetX1) / totalTilesX) * totalTilesX + offsetX2;
	
	int offsetY1 = totalTilesY / 2 + 1 - (tileNumberY + 1);
	int offsetY2 = tileNumberY;
	int newIndexY = ((currentCenterIndexY + offsetY1) / totalTilesY) * totalTilesY + offsetY2;
	
	if (newIndexX >= limitTilesX ||newIndexY >= limitTilesY) {
	//	self.hidden = YES;
		indexX = newIndexX;
		indexY = newIndexY;
	}
	else if (indexX != newIndexX || indexY != newIndexY) {
	//	self.hidden = NO;
		indexX = newIndexX;
		indexY = newIndexY;
		
		CGRect rect = self.frame;
		rect.origin.x = rect.size.width * newIndexX;
		rect.origin.y = rect.size.height * newIndexY;
		self.frame = rect;
		self.tileNumberString = [NSString stringWithFormat:@"Num:%d", tileNumberX + totalTilesX * tileNumberY];
		self.indexString = [NSString stringWithFormat:@"Idx:%d,%d", indexX, indexY];
		[self setNeedsDisplay];
	}
}

#pragma mark -
#pragma mark Override

- (void)drawRect:(CGRect)rect {
#ifdef _TILE_NUMBER
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(context, 1.f, 1.f, 1.f, 1.f);
	[self.tileNumberString drawAtPoint:CGPointMake(20, 20) withFont:[UIFont boldSystemFontOfSize:20]];
	[self.indexString drawAtPoint:CGPointMake(20, 40) withFont:[UIFont boldSystemFontOfSize:20]];
#endif
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[backColor release];
	[indexString release];
	[tileNumberString release];
    [super dealloc];
}

@end

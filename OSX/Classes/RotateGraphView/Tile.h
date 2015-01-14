//
//  Tile.h
//  StoreSales
//
//  Created by sonson on 09/03/27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Tile : UIView {
	int			indexX;
	int			indexY;
	int			tileNumberX;
	int			tileNumberY;
	int			totalTilesX;
	int			totalTilesY;
	UIColor		*backColor;
	NSString	*indexString;
	NSString	*tileNumberString;
	
	int			limitTilesX;
	int			limitTilesY;
}
@property (nonatomic, assign) int limitTilesX;
@property (nonatomic, assign) int limitTilesY;
@property (nonatomic, retain) NSString* indexString;
@property (nonatomic, retain) NSString* tileNumberString;
#pragma mark Original method
- (id)initWithFrame:(CGRect)frame titleNumberX:(int)numX totalTilesX:(int)totalX titleNumberY:(int)numY totalTilesY:(int)totalY;
- (void)resetTileInfo;
#pragma mark Update Tile Number X,Y
- (void)setCurrentIndexX:(int)currentCenterIndexX indexY:(int)currentCenterIndexY;
@end

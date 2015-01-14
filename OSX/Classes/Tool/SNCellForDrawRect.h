//
//  SNTableViewCellDrawRect.h
//  2tch
//
//  Created by sonson on 08/10/24.
//  Copyright 2008 sonson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNCellForDrawRect : UITableViewCell {
	BOOL						originalHighlightedFlag;
	BOOL					canSelect;
}
@property (nonatomic, assign) BOOL canSelect;
@property (nonatomic, readonly) BOOL originalHighlightedFlag;
- (void)drawBackground:(CGRect)rect;
- (void)drawBackgroundWithGradient:(CGRect)rect;
@end

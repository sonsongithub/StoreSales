//
//  ContentViewController.h
//  StoreSales
//
//  Created by sonson on 09/10/17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class InfoContentViewController;

@interface ContentViewController : NSViewController {
	id	contentInfo;
	id	controller;
}
@property(nonatomic, retain) id contentInfo;

#pragma mark -
#pragma mark Accessor
- (void)setContentInfo:(id)newValue;

#pragma mark -
#pragma mark Instance method
- (void)reloadContent;

@end

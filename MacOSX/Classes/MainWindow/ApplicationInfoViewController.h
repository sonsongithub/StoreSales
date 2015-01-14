//
//  ApplicationInfoViewController.h
//
//  Created by sonson on 09/10/17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ApplicationInfo;
@class AppIconView;
@class AppIconReflectedView;

@interface ApplicationInfoViewController : NSViewController {
	IBOutlet AppIconView	*iconView2;
	IBOutlet AppIconReflectedView	*iconView;
	IBOutlet NSImageView	*imageView;
	IBOutlet NSTextField	*titleField;
	ApplicationInfo			*contentInfo;
	
}
@property(nonatomic, retain) ApplicationInfo *contentInfo;
@end

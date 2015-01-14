//
//  AppIconView.h
//  StoreSales
//
//  Created by sonson on 09/10/17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppIconView : NSView {
	IBOutlet NSImage *image;
}
@property(nonatomic, copy) NSImage *image;
@end

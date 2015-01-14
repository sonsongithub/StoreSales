//
//  AppIconReflectedView.h
//  StoreSales
//
//  Created by sonson on 09/10/18.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppIconReflectedView : NSView {
	IBOutlet NSImage *image;
}
@property(nonatomic, copy) NSImage *image;
@end

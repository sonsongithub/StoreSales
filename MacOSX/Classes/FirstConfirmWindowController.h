//
//  FirstConfirmWindowController.h
//  StoreSales
//
//  Created by sonson on 09/10/06.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FirstConfirmWindowController : NSWindowController {
	IBOutlet NSButton *checkButton;
}
- (IBAction)pusuOKButton:(id)sender;
+ (FirstConfirmWindowController*)defaultController;
- (void)show;
@end

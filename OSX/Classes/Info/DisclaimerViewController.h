//
//  DisclaimerViewController.h
//  StoreSales
//
//  Created by sonson on 09/09/27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DisclaimerViewController : UIViewController {
	IBOutlet UITextView *textview;
}
+ (DisclaimerViewController*)defaultController;
@end

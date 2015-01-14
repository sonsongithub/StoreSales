//
//  SNAlertViewAccountInput.h
//  alertView
//
//  Created by sonson on 09/04/06.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SNAlertViewAccountInput : UIAlertView {
	UITextField	*usernameField;
	UITextField	*passwordField;
}
@property (nonatomic, retain) UITextField *usernameField;
@property (nonatomic, retain) UITextField *passwordField;
- (id)initWithTitle:(NSString*)title delegate:(id)aDelegate;
@end

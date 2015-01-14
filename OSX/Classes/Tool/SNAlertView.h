//
//  SNAlertView.h
//  dharma
//
//  Created by sonson on 09/01/22.
//  Copyright 2009 sonson. All rights reserved.
// MIT License

#import <UIKit/UIKit.h>

@interface SNAlertView : UIAlertView {
	NSMutableArray		*fieldArray;
	NSMutableDictionary	*fieldTable;
	BOOL				isLayouted;
	CGSize				keyboardSize;
}
- (void)registerForKeyboardNotifications;
- (void)keyboardWillShow:(NSNotification*)aNotification ;
#pragma mark Access to TextFields
- (NSArray*)textFieldTags;
- (NSInteger)textFieldCount;
- (UITextField*)textFieldWithTag:(NSString*)tag ;
- (UITextField*)textFieldAtIndex:(NSInteger)index;
- (BOOL)addTextFieldDefaultValue:(NSString*)value placeholder:(NSString*)placeholder tag:(NSString*)tag;
#pragma mark Layout helper
- (float)heightOfLabelArea;
- (float)heightOfFields;
@end

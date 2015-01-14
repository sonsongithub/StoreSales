//
//  SNAlertView.m
//  dharma
//
//  Created by sonson on 09/01/22.
//  Copyright 2009 sonson. All rights reserved.
// MIT License.
//

#import "SNAlertView.h"

#define HEIGHT_OF_FIELD			30.0
#define X_MARGIN_OF_FIELD		10.0
#define Y_MARGIN_OF_FIELD		10.0
#define KEYBOARD_HEIGHT			216

@implementation SNAlertView

#pragma mark Original Method

#pragma mark Keyborad

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
	keyboardSize = [aValue CGRectValue].size;
}

#pragma mark Access to TextFields

- (NSArray*)textFieldTags {
	return [fieldTable allKeys];
}

- (NSInteger)textFieldCount {
	return [fieldArray count];
}

- (UITextField*)textFieldWithTag:(NSString*)tag {
	return [fieldTable objectForKey:tag];
}

- (UITextField*)textFieldAtIndex:(NSInteger)index {
	if( index > 0 && index < [fieldArray count] )
		return [fieldArray objectAtIndex:index];
	return nil;
}

- (BOOL)addTextFieldDefaultValue:(NSString*)value placeholder:(NSString*)placeholder tag:(NSString*)tag {
	
	UITextField* aField = [[UITextField alloc] initWithFrame:CGRectZero];
	aField.text = value;
	aField.placeholder = placeholder;
	aField.autocorrectionType = UITextAutocorrectionTypeNo;
	aField.borderStyle = UITextBorderStyleRoundedRect;
	[fieldTable setObject:aField forKey:tag];
	[fieldArray addObject:aField];
	[self addSubview:aField];
	[aField release];
	
	return YES;
}

#pragma mark Layout helper

- (float)heightOfLabelArea {
	CGFloat maxY = 0;
	for( UIView *view in self.subviews ){
		if([view isKindOfClass:[UILabel class]]) {
			CGRect viewFrame = [view frame];
			CGFloat lowerY = viewFrame.origin.y + viewFrame.size.height;
			if(lowerY > maxY)
				maxY = lowerY;
		}
	}
	return maxY;
}

- (float)heightOfFields {
	float offset = [fieldArray count] * HEIGHT_OF_FIELD + ([fieldArray count] + 1 ) * Y_MARGIN_OF_FIELD;
	return offset;
}

#pragma mark Override

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate 
  cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
	self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle
			  otherButtonTitles:otherButtonTitles, nil];
	fieldTable = [[NSMutableDictionary alloc] init];
	fieldArray = [[NSMutableArray alloc] init];
	[self registerForKeyboardNotifications];
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect originalFrame = self.frame;
	
	float heightOfLabelArea =  [self heightOfLabelArea];
	float y = heightOfLabelArea + Y_MARGIN_OF_FIELD;
	for( UITextField* view in fieldArray ) {
		CGRect viewFrame = CGRectMake( X_MARGIN_OF_FIELD, y, originalFrame.size.width - X_MARGIN_OF_FIELD*2, HEIGHT_OF_FIELD);
		y += ( HEIGHT_OF_FIELD + Y_MARGIN_OF_FIELD );
		[view setFrame:viewFrame];
	}
	
	float bottomButtonArea = 0;
	for( UIView *view in self.subviews ){
		if( ![view isKindOfClass:[UILabel class]] && ![view isKindOfClass:[UITextField class]]) {
			CGRect viewFrame = [view frame];
			viewFrame.origin.y = y;
			[view setFrame:viewFrame];
			if( bottomButtonArea < viewFrame.origin.y + viewFrame.size.height ) 
				bottomButtonArea = viewFrame.origin.y + viewFrame.size.height;
		}
	}
	originalFrame.size.height = bottomButtonArea + 15;
	self.frame = originalFrame;
	if( !isLayouted ) {
		[[fieldArray objectAtIndex:0] becomeFirstResponder];
		UIScreen *screen = [UIScreen mainScreen];
		self.center = CGPointMake( (int)(screen.applicationFrame.size.width / 2), (int)(( screen.applicationFrame.size.height - KEYBOARD_HEIGHT + 20 ) /2)  );
		isLayouted = YES;
	}
	else {
	}
}

- (void)show {
	isLayouted = NO;
	[super show];
}

#pragma mark dealloc

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[fieldTable release];
	[fieldArray release];
	[super dealloc];
}

@end

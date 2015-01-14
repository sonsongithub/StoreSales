//
//  SNActionSheetController.h
//  StoreSales
//
//  Created by sonson on 09/05/30.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *kSNActionProgressIncrementStep;

@interface SNActionSheetController : NSObject <UIActionSheetDelegate> {
	UIActionSheet	*sheet;
	
	UIProgressView	*progress;
	UILabel			*targetLabel;
	
	int				allSteps;
	int				step;
}
@property (nonatomic, assign) int step;
@property (nonatomic, assign) int allSteps;

#pragma mark -
#pragma mark Class method
+ (SNActionSheetController*)sharedInstance;
#pragma mark -
#pragma mark User interface
- (void)updateTargetLabel:(NSString*)string;
- (void)showInView:(UIView*)view;
- (void)dismiss;
- (void)incrementStepForNotification:(NSNotification*)notification;
- (void)incrementStep;
- (void)setStep:(int)newValue;
- (void)setAllSteps:(int)newValue;

@end

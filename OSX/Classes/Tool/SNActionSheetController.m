//
//  SNActionSheetController.m
//  StoreSales
//
//  Created by sonson on 09/05/30.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SNActionSheetController.h"

SNActionSheetController *sharedInstanceSNActionSheetController = nil;

NSString *kSNActionProgressIncrementStep = @"kSNActionProgressIncrementStep";

@implementation SNActionSheetController

@dynamic step, allSteps;

#pragma mark -
#pragma mark Class method

+ (SNActionSheetController*)sharedInstance {
	if (sharedInstanceSNActionSheetController == nil) {
		sharedInstanceSNActionSheetController = [[SNActionSheetController alloc] init];
	}
	return sharedInstanceSNActionSheetController;
}

#pragma mark -
#pragma mark User interface

- (void)updateTargetLabel:(NSString*)string {
	CGRect frame = sheet.bounds;
	targetLabel.text = string;
	CGRect rect = [targetLabel textRectForBounds:CGRectMake(0,0,300,100) limitedToNumberOfLines:1];
	rect.origin.x = (int)((frame.size.width - rect.size.width) / 2);
	rect.origin.y = 75;
	targetLabel.frame = rect;
}

- (void)showInView:(UIView*)view {
	[sheet showInView:UIAppDelegate.window];
	CGRect frame = sheet.bounds;
	frame.size.height += 100;

	CGRect bounds = progress.bounds;
	bounds.size.width = frame.size.width * 0.9;
	progress.bounds = bounds;
	progress.center = CGPointMake(frame.size.width/2, frame.size.height * 0.6);
	
	// update sheet size
	sheet.bounds = frame;
	
	//
	// Initialize, UI as label and progress bar 
	//
	progress.progress = 0;
	[self updateTargetLabel:@""];
}

- (void)dismiss {
	[sheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)incrementStepForNotification:(NSNotification*)notification {
	[self incrementStep];
}

- (void)incrementStep {
	step++;
	progress.progress = (float)step/allSteps;
}

- (void)setStep:(int)newValue {
	step = newValue;
	progress.progress = (float)step/allSteps;
}

- (void)setAllSteps:(int)newValue {
	allSteps = newValue;
	progress.progress = (float)step/allSteps;
}

#pragma mark -
#pragma mark Override

- (id)init {
	self = [super init];
	sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:nil];
	
	//
	// setup title label
	//
	targetLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	[sheet addSubview:targetLabel];
	[targetLabel release];
	targetLabel.font = [UIFont boldSystemFontOfSize:12];
	targetLabel.textColor = [UIColor whiteColor];
	targetLabel.shadowColor = [UIColor blackColor];
	targetLabel.backgroundColor = [UIColor clearColor];
	targetLabel.shadowOffset = CGSizeMake( 0, -1 );
	targetLabel.textAlignment = UITextAlignmentCenter;
	[self updateTargetLabel:NSLocalizedString(@"", nil)];
	
	//
	// setup progress view
	//
	progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
	[sheet addSubview:progress];
	[progress release];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(incrementStepForNotification:)
												 name:kSNActionProgressIncrementStep
											   object:nil];
	
	return self;
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[sheet release];
	[super dealloc];
}


@end

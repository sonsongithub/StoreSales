//
//  DisclaimerViewController.m
//  StoreSales
//
//  Created by sonson on 09/09/27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DisclaimerViewController.h"


@implementation DisclaimerViewController

+ (DisclaimerViewController*)defaultController {
	DisclaimerViewController* controller = [[DisclaimerViewController alloc] initWithNibName:nil bundle:nil];
	return [controller autorelease];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"disclaimer" ofType:@"txt"];
	
	NSString *body = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	textview.text = body;
	
	self.title = NSLocalizedString(@"Disclaimer", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
    [super dealloc];
}


@end

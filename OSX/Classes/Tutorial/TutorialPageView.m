//
//  TutorialPageView.m
//  TutorialTest
//
//  Created by sonson on 09/09/19.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TutorialPageView.h"
#import "MessageView.h"

NSMutableArray *images = nil;
NSMutableArray *messages = nil;
NSMutableArray *titles = nil;

@implementation TutorialPageView

@dynamic page, pageTitle;

#pragma mark -
#pragma mark Class method

+ (void)initialize {
	images = [[NSMutableArray array] retain];
	messages = [[NSMutableArray array] retain];
	titles = [[NSMutableArray array] retain];
	
	[images addObject:[UIImage imageNamed:@"page01.png"]];
	[messages addObject:NSLocalizedString(@"Thank you for downloading StoreSales!!", nil)];
	[titles addObject:NSLocalizedString(@"Tutorial", nil)];
	
	[images addObject:[UIImage imageNamed:@"page02.png"]];
	[messages addObject:NSLocalizedString(@"StoreSales needs Mac, iPhone and WiFi to communicate between them. StoreSales uses WiFi network to send sales log files from Mac to iPhone.", nil)];
	[titles addObject:NSLocalizedString(@"Condition", nil)];
	
	[images addObject:[UIImage imageNamed:@"page03.png"]];
	[messages addObject:NSLocalizedString(@"At first, you have to download and install StoreSales for MacOSX via http://son-son.sakura.ne.jp/app_store/storesales_en.html. You can download it via this URL.", nil)];
	[titles addObject:NSLocalizedString(@"Setup MacOSX", nil)];
	
	[images addObject:[UIImage imageNamed:@"page04.png"]];
	[messages addObject:NSLocalizedString(@"Run StoreSales for MacOSX, you can change the path of 'Log File Folder' with 'Choose Log File Folder'. The default path is '~/Library/Application Support/StoreSales/log'.", nil)];
	[titles addObject:NSLocalizedString(@"Log File Folder", nil)];
	
	[images addObject:[UIImage imageNamed:@"page05.png"]];
	[messages addObject:NSLocalizedString(@"Copy sales log files into 'Log File Folder', which you want to send to iPhone.", nil)];
	[titles addObject:NSLocalizedString(@"Copy files", nil)];
	
	[images addObject:[UIImage imageNamed:@"page06.png"]];
	[messages addObject:NSLocalizedString(@"Next setup pairing. Turn back to iPhone, run StoreSales on iPhone. And then push 'Sync' button.", nil)];
	[titles addObject:NSLocalizedString(@"First step", nil)];
	
	[images addObject:[UIImage imageNamed:@"page07.png"]];
	[messages addObject:NSLocalizedString(@"Sync view is opened. Select 'Pairing with Your Mac'.", nil)];
	[titles addObject:NSLocalizedString(@"Sync view", nil)];
	
	[images addObject:[UIImage imageNamed:@"page08.png"]];
	[messages addObject:NSLocalizedString(@"This passcode is used to authorize your iPhone by your Mac. Keep iPhone displaying this passcode. Next, input this number into StoreSales for MacOSX.", nil)];
	[titles addObject:NSLocalizedString(@"Passcode", nil)];
	
	[images addObject:[UIImage imageNamed:@"page09.png"]];
	[messages addObject:NSLocalizedString(@"Select 'StoreSales' icon on the system menu bar, and select 'Pairing with new device' to open pairing view.", nil)];
	[titles addObject:NSLocalizedString(@"on MacOSX", nil)];
	
	[images addObject:[UIImage imageNamed:@"page10.png"]];
	[messages addObject:NSLocalizedString(@"Device list panel is opened. Push 'Pairing' button of your iPhone device.", nil)];
	[titles addObject:NSLocalizedString(@"Pairing", nil)];
	
	[images addObject:[UIImage imageNamed:@"page11.png"]];
	[messages addObject:NSLocalizedString(@"Please input the passcode which is currently shown on your iPhone.", nil)];
	[titles addObject:NSLocalizedString(@"Input Passcode", nil)];
	
	[images addObject:[UIImage imageNamed:@"page12.png"]];
	[messages addObject:NSLocalizedString(@"If you already have finished pairing your Mac, and then the receiving button is shown on iPhone's sync view.", nil)];
	[titles addObject:NSLocalizedString(@"Finished pairing", nil)];
	
	[images addObject:[UIImage imageNamed:@"page13.png"]];
	[messages addObject:NSLocalizedString(@"Selecting 'Receive sales log from Mac', you can receive sales log from your Mac.", nil)];
	[titles addObject:NSLocalizedString(@"Receive sales log", nil)];
	
	[images addObject:[UIImage imageNamed:@"page14.png"]];
	[messages addObject:NSLocalizedString(@"Open confirmation sheet on Mac and then push OK after checking device name.", nil)];
	[titles addObject:NSLocalizedString(@"Receive sales log", nil)];
	
	[images addObject:[UIImage imageNamed:@"page15.png"]];
	[messages addObject:NSLocalizedString(@"Thank you for your reading!!", nil)];
	[titles addObject:NSLocalizedString(@"StoreSales", nil)];
	
}

+ (int)totalPage {
	return [images count];
}

+ (NSString*)titleOfPage:(int)page {
	if (page < [titles count])
		return [titles objectAtIndex:page];
	return nil;
}

+ (NSString*)messageOfPage:(int)page {
	if (page < [messages count])
		return [messages objectAtIndex:page];
	return nil;
}

+ (UIImage*)imageOfPage:(int)page {
	if (page < [images count])
		return [images objectAtIndex:page];
	return nil;
}

#pragma mark -
#pragma mark Accessor

- (NSString*)pageTitle {
	return [[self class] titleOfPage:page];
}

- (void)setPage:(int)newValue {
	if (page != newValue) {
		page = newValue;
		[self reloadContent];
	}
}

#pragma mark -
#pragma mark Instance method

- (void)reloadContent {
	[imageview removeFromSuperview];
	imageview = [[UIImageView alloc] initWithImage:[[self class] imageOfPage:page]];
	[self.view addSubview:[imageview autorelease]];
	
	[messageview removeFromSuperview];
	messageview= [[MessageView alloc] initWithMessage:[[self class] messageOfPage:page]];
	[self.view addSubview:[messageview autorelease]];
	CGRect frame = messageview.frame;
	frame.origin.x = (int)(self.view.frame.size.width - messageview.frame.size.width)/2;
	frame.origin.y = (int)(imageview.frame.size.height - messageview.bounds.size.height);
	messageview.frame = frame;
}

#pragma mark -
#pragma mark Override

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.view.backgroundColor = [UIColor colorWithRed:143.0f/255.0f green:145.0f/255.0f blue:146.0f/255.0f alpha:255.0f/255.0f];
		[self reloadContent];
    }
    return self;
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
    [super dealloc];
}

@end

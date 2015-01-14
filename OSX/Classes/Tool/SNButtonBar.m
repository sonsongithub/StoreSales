//
//  SNButtonBar.m
//  StoreSales
//
//  Created by sonson on 09/02/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SNButtonBar.h"

UIImage*	SNButtonBarPushedBackgroundImage = nil;
UIImage*	SNButtonBarNormalBackgroundImage = nil;

UIFont*		SNButtonBarFont = nil;

UIColor*	SNButtonBarPushedTitleColor = nil;
UIColor*	SNButtonBarNormalTitleColor = nil;
UIColor*	SNButtonBarPushedShadowColor = nil;
UIColor*	SNButtonBarNormalShadowColor = nil;

@implementation SNButtonBar

@synthesize buttons;
@synthesize selectedIndex;
@synthesize delegate;

#pragma mark -
#pragma mark Class method

+ (void)initialize {
	if (SNButtonBarNormalBackgroundImage == nil) {
		UIImage* org = [UIImage imageNamed:@"barButtonNormal.png"];
		SNButtonBarNormalBackgroundImage = [[org stretchableImageWithLeftCapWidth:16 topCapHeight:17] retain];
	}
	if (SNButtonBarPushedBackgroundImage == nil) {
		UIImage* org = [UIImage imageNamed:@"barButtonPushed.png"];
		SNButtonBarPushedBackgroundImage = [[org stretchableImageWithLeftCapWidth:16 topCapHeight:17] retain];
	}
	if (SNButtonBarFont == nil) {
		SNButtonBarFont = [[UIFont boldSystemFontOfSize:13] retain];
	}
	if (SNButtonBarPushedTitleColor == nil) {
		SNButtonBarPushedTitleColor = [[UIColor whiteColor] retain];
	}
	if (SNButtonBarNormalTitleColor == nil) {
		SNButtonBarNormalTitleColor = [[UIColor colorWithRed:63/255.0f green:92/255.0f blue:132/255.0f alpha:1.0f] retain];
	}
	if (SNButtonBarPushedShadowColor == nil) {
		SNButtonBarPushedShadowColor = [[UIColor colorWithRed:64/255.0f green:64/255.0f blue:64/255.0f alpha:1.0f] retain];
	}
	if (SNButtonBarNormalShadowColor == nil) {
		SNButtonBarNormalShadowColor = [[UIColor whiteColor] retain];
	}
}

+ (SNButtonBar*)buttonBarWithTitles:(NSArray*)titles {
	SNButtonBar *buttonBar = [[[SNButtonBar alloc] initWithFrame:CGRectMake(0, 0, 320, 35)] autorelease];
	[buttonBar setupWithTitles:titles];
	return buttonBar;
}

#pragma mark -
#pragma mark Instance method

- (void)setSelectedIndexWithCellOrderType:(CellOrderType)orderType {
	switch (orderType) {
		case CellOrderSales:
			[self setSelectedIndex:0];
			break;
		case CellOrderUnits:
			[self setSelectedIndex:1];
			break;
		case CellOrderUpgrade:
			[self setSelectedIndex:2];
			break;
		default:
			break;
	}
}

- (void)setSelectedIndex:(int)newValue {
	if (selectedIndex != newValue && selectedIndex < [buttons count] ) {
		selectedIndex = newValue;
		[self pushButton:[buttons objectAtIndex:selectedIndex]];
	}	
}

- (void)pushButton:(id)sender {
	DNSLogMethod
	for (int i = 0; i < [buttons count]; i++) {
		UIButton *button = [buttons objectAtIndex:i];
		if (button == sender) {
			[button setBackgroundImage:SNButtonBarPushedBackgroundImage forState:UIControlStateNormal];
			[button setTitleColor:SNButtonBarPushedTitleColor forState:UIControlStateNormal];
			[button setTitleShadowColor:SNButtonBarPushedShadowColor forState:UIControlStateNormal];
			if (i != selectedIndex) {
				// delegate
				[delegate buttonBar:self didChangeSelectedIndex:i];
			}
			selectedIndex = i;
		}
		else {
			[button setBackgroundImage:SNButtonBarNormalBackgroundImage forState:UIControlStateNormal];
			[button setTitleColor:SNButtonBarNormalTitleColor forState:UIControlStateNormal];
			[button setTitleShadowColor:SNButtonBarNormalShadowColor forState:UIControlStateNormal];
		}
	}
}

- (void)setupWithTitles:(NSArray*)titles {
	int width = self.frame.size.width / [titles count];
	self.buttons = [NSMutableArray array];
	selectedIndex = 0;
	for (int i = 0; i < [titles count]; i++) {
		NSString *title = [titles objectAtIndex:i];
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setTitle:title forState:UIControlStateNormal];
		[button.titleLabel setShadowOffset:CGSizeMake( 0, 1.2)];
		
		button.titleLabel.font = SNButtonBarFont;
		
		button.titleLabel.textColor = SNButtonBarPushedTitleColor;//
		
		[button setBackgroundImage:SNButtonBarPushedBackgroundImage forState:UIControlStateHighlighted];
		[button setTitleColor:SNButtonBarPushedTitleColor forState:UIControlStateHighlighted];
		[button setTitleShadowColor:SNButtonBarPushedShadowColor forState:UIControlStateHighlighted];
		
		[button addTarget:self action:@selector(pushButton:) forControlEvents:UIControlEventTouchDown];
		[self addSubview:button];
		if (i == [titles count] - 1) {
			// padding last 1 pixel when total buttons' width isn't an integer.
			button.frame = CGRectMake(width * i, 0, self.frame.size.width - width * i, 35);
		}
		else {
			button.frame = CGRectMake(width * i, 0, width, 35);
		}
		[buttons addObject:button];
	}
	[self pushButton:[buttons objectAtIndex:selectedIndex]];
}

#pragma mark -
#pragma mark Override

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[self.buttons release];
    [super dealloc];
}

@end

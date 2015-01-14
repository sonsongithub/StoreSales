//
//  LineChartView.m
//  StoreSales
//
//  Created by sonson on 09/03/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LineChartView.h"
#import "PeriodicalSales.h"
#import "Tile.h"
#import "LineChartData.h"
#import "LineChartTile.h"
#import "LineChartMeasureView.h"

UIColor *LineChartRedColor = nil;
UIColor *LineChartGreenColor = nil;
UIColor *LineChartEmerardColor = nil;
UIColor *LineChartWhiteColor = nil;

@implementation LineChartView

@synthesize chartData;
@synthesize baseScrollView;
@synthesize views;
@synthesize measureView;
@synthesize title;
@synthesize subtitle;

+ (void)initialize {
	if (LineChartRedColor == nil) {
		LineChartRedColor = [[UIColor colorWithRed:147.0f / 255.0 green:47.0f / 255.0 blue:39.0f / 255.0 alpha:1.0] retain];
	}
	if (LineChartGreenColor == nil) {
		LineChartGreenColor = [[UIColor colorWithRed:90 / 255.0 green:162 / 255.0 blue:39.0f / 255.0 alpha:1.0] retain];
	}
	if (LineChartEmerardColor == nil) {
		LineChartEmerardColor = [[UIColor colorWithRed:97.0 / 255.0 green:170.0f / 255.0 blue:170.0f / 255.0 alpha:1.0] retain];
	}
	if (LineChartWhiteColor == nil) {
		LineChartWhiteColor = [[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0] retain];
	}
}

#pragma mark -
#pragma mark Original method

+ (UIColor*)colorOfLineChart:(CellOrderType)orderType {
	switch(orderType) {
		case CellOrderSales:
			return LineChartRedColor;
		case CellOrderUnits:
			return LineChartGreenColor;
		case CellOrderUpgrade:
			return LineChartEmerardColor;
		default:
			return LineChartWhiteColor;
	}
}

- (void)updateData {
	// dummy
	DNSLogMethod
}

- (void)willUpdateData {
	// dummy
}

- (void)startUpIndicator {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@synchronized(indicator) {
		[indicator startAnimating];
	}
	[pool release];
	[NSThread exit];
}

- (void)swipedUp {
	DNSLogMethod
	CGRect rect = measureView.frame;
	[UIView beginAnimations:@"ShowMeasureView" context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(willUpdateData)];
	rect.origin.x = -rect.size.width;
	measureView.frame = rect;
	[UIView commitAnimations];
	[indicator startAnimating];
}

- (void)setupMeasureView {
	CGRect rect = measureView.frame;
	[UIView beginAnimations:@"ShowMeasureView" context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(didShowMeasureView)];
	rect.origin.x = 0;
	measureView.frame = rect;
	[UIView commitAnimations];
}

- (void)didShowMeasureView {
	BOOL IsNotFirstUseOfLineChart = [[NSUserDefaults standardUserDefaults] boolForKey:@"IsNotFirstUseOfLineChart"];
	if (!IsNotFirstUseOfLineChart) {
		UIAlertView *view = [[UIAlertView alloc] initWithTitle:nil 
													   message:NSLocalizedString(@"You can change the graph with double tap.", nil)
													  delegate:nil
											 cancelButtonTitle:nil
											 otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
		[view show];
		[view release];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IsNotFirstUseOfLineChart"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	[indicator stopAnimating];
}

- (void)rebuildContentSizeAndTiles {
	// calc a number of views 
	int dateCount = [self.chartData count];
	int datePerView = DATE_PER_VIEW;
	int count = dateCount / datePerView;
	if (dateCount % datePerView > 0) {
		count++;
	}
	
	// calc parent UIScrollView's content size
	baseScrollView.contentSize = CGSizeMake(480 * (float)dateCount / datePerView/* + baseScrollView.contentInset.left*/, 300 * 1);
	// when use auto scroll latest date
	// baseScrollView.contentOffset = CGPointMake(480 * (float)dateCount / datePerView - self.frame.size.width, 0);
	// baseScrollView.contentOffset = CGPointMake(-baseScrollView.contentInset.left, 0);
	int centerIndexX = (int)(baseScrollView.contentOffset.x / 480);
	int centerIndexY = (int)(baseScrollView.contentOffset.y / 300);
	
	DNSLog(@"%d/%d", dateCount, datePerView);
	DNSLog(@"%f", 480 * (float)dateCount / datePerView);

	// setup tiles
	for (LineChartTile *tile in views) {
		[tile resetTileInfo];
		[tile setCurrentIndexX:centerIndexX indexY:centerIndexY];
		tile.limitTilesX = count;
		tile.limitTilesY = 1;
		tile.lineChartDataArray = self.chartData;
		tile.delegate = self;
		[tile setNeedsDisplay];
	}
}

- (void)updateMaxValue {
	DNSLogMethod
	// calc min and max value.
	LineChartData *p = [self.chartData lastObject];
	float max_value = p.value;
	float min_value = p.value;
	
	// search min and max
	for (LineChartData *data in self.chartData) {
		if (data.value >= 0) {
			if (data.value > max_value) {
				max_value = data.value;
			}
			if (data.value < min_value) {
				min_value = data.value;
			}
		}
	}
	DNSLog(@"%f < value < %f", min_value, max_value);
	
	// calc maximum measure value
	max_value_measure = 0;
	float log_ = log10(max_value);
	max_value_measure = pow(10, ((int)log_ + 1));
	if (max_value < max_value_measure/4) {
		max_value_measure = max_value_measure / 4;
	}
	else if (max_value < max_value_measure/2) {
		max_value_measure = max_value_measure / 2;
	}
	for (LineChartData *data in self.chartData) {
		data.ratio = data.value / max_value_measure;
	}
	
	// update measure
	[measureView setupMeasureString:max_value_measure];
	baseScrollView.contentInset = UIEdgeInsetsMake(0, measureView.frame.size.width, 0, 0);
	[measureView setNeedsDisplay];
}

#pragma mark -
#pragma mark Override

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.baseScrollView = [[UIScrollView alloc] initWithFrame:frame];
		[self addSubview:baseScrollView];
		baseScrollView.alwaysBounceHorizontal = NO;
		baseScrollView.showsHorizontalScrollIndicator = NO;
		baseScrollView.showsVerticalScrollIndicator = NO;
		baseScrollView.delegate = self;
		[self.baseScrollView release];
		
		self.measureView = [LineChartMeasureView defaultView];
		[self addSubview:measureView];
		
		CGRect rect = measureView.frame;
		rect.origin.x = -rect.size.width;
		measureView.frame = rect;
		
		// realloc tiles buffer
		self.views = [NSMutableArray array];
		
		// tile buffer size
		float tile_max_x = 3;
		float tile_max_y = 1;
		
		indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[self addSubview:indicator];
		CGRect indicatorFrame = indicator.frame;
		indicatorFrame.origin.x = (int)(frame.size.width - indicatorFrame.size.width)/2;
		indicatorFrame.origin.y = (int)(frame.size.height - indicatorFrame.size.height)/2;
		indicator.frame = indicatorFrame;
		
		// setup tiles
		for (int i = 0; i < tile_max_x; i++) {
			for (int j = 0; j < tile_max_y; j++) {
				LineChartTile* view = [[LineChartTile alloc] initWithFrame:CGRectMake(0, 0, 480, 300) titleNumberX:i totalTilesX:tile_max_x titleNumberY:j totalTilesY:tile_max_y];
				[baseScrollView addSubview:view];
				[view setCurrentIndexX:0 indexY:0];
				view.limitTilesX = 10;
				view.limitTilesY = 1;
				view.lineChartDataArray = self.chartData;
				view.delegate = self;
				[view setNeedsDisplay];
				[views addObject:view];
				[view release];
			}
		}
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextSetLineWidth(context, 2.0);
	CGContextMoveToPoint(context, 0.0, TOP_MARGIN_BOTTOM_LINE);
	CGContextAddLineToPoint(context, 480.0, TOP_MARGIN_BOTTOM_LINE);
	CGContextStrokePath(context);
	
	for (int i = 1; i <= 4; i++) {
		if (i%2) {
			CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.1);
		}
		else {
			CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.5);
		}
		float y =  convertY(1.0/4*(i));
		CGContextSetLineWidth(context, 1.0);
		CGContextMoveToPoint(context, 0.0, y);
		CGContextAddLineToPoint(context, 480.0, y);
		CGContextStrokePath(context);
	}
	
	CGContextSaveGState(context);
	CGContextAlternativeSetShadowWithColor(context, CGSizeMake(0, 0), 2.0, [UIColor blackColor].CGColor);
	CGRect titleRect;
	CGContextSetRGBFillColor(context, 1, 1, 1, 1);
	titleRect.size = [self.title sizeWithFont:[UIFont boldSystemFontOfSize:12]];
	titleRect.origin.x = 240 - titleRect.size.width/2;
	titleRect.origin.y = 2;
	[self.title drawAtPoint:titleRect.origin withFont:[UIFont boldSystemFontOfSize:12]];
	
	CGRect subtitleRect;
	//self.subtitle = @"A";
	CGContextSetRGBFillColor(context, 1, 1, 1, 1);
	subtitleRect.size = [self.subtitle sizeWithFont:[UIFont boldSystemFontOfSize:12]];
	subtitleRect.origin.x = 240 - subtitleRect.size.width/2;
	subtitleRect.origin.y = 17;
	[self.subtitle drawAtPoint:subtitleRect.origin withFont:[UIFont boldSystemFontOfSize:12]];
	
	if ([self.chartData count] == 0) {
		NSString *nodataTitle = NSLocalizedString(@"no data", nil);
		CGRect nodataTitleRect;
		nodataTitleRect.size = [nodataTitle sizeWithFont:[UIFont boldSystemFontOfSize:24]];
		nodataTitleRect.origin.x = 240 - nodataTitleRect.size.width/2;
		nodataTitleRect.origin.y = 150 - nodataTitleRect.size.height/2;
		[nodataTitle drawAtPoint:nodataTitleRect.origin withFont:[UIFont boldSystemFontOfSize:24]];
	}
	CGContextRestoreGState(context);
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	int centerIndexX = (int)(baseScrollView.contentOffset.x / 480);
	int centerIndexY = (int)(baseScrollView.contentOffset.y / 300);
	for (Tile *view in views) {
		[view setCurrentIndexX:centerIndexX indexY:centerIndexY];
	}
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[indicator release];
	[title release];
	[subtitle release];
	[measureView release];
	[views release];
	[baseScrollView release];
	[chartData release];
    [super dealloc];
}

@end

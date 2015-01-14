//
//  SelectOrderViewController.m
//  StoreSales
//
//  Created by sonson on 09/03/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SelectOrderViewController.h"
#import "AppDailyViewController.h"
#import "AppWeeklyViewController.h"
#import "AppCountriesViewController.h"

@implementation SelectOrderViewController

@synthesize appleIdentifier;
@synthesize sales;

#pragma mark -
#pragma mark UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell1";
	UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = NSLocalizedString(@"Daily Reports", nil);
			cell.imageView.image = [UIImage imageNamed:@"dailyNormal.png"];
			cell.imageView.highlightedImage = [UIImage imageNamed:@"dailyWhite.png"];
			break;
		case 1:
			cell.textLabel.text = NSLocalizedString(@"Weekly Reports", nil);
			cell.imageView.image = [UIImage imageNamed:@"weeklyNormal.png"];
			cell.imageView.highlightedImage = [UIImage imageNamed:@"weeklyWhite.png"];
			break;
		case 2:
			cell.textLabel.text = NSLocalizedString(@"Countries", nil);
			cell.imageView.image = [UIImage imageNamed:@"countriesNormal.png"];
			cell.imageView.highlightedImage = [UIImage imageNamed:@"countriesWhite.png"];
			break;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	if (indexPath.row == 0) {
		AppDailyViewController *con = [[AppDailyViewController alloc] initWithStyle:UITableViewStylePlain];
		con.currentSales = sales;
		[self.navigationController pushViewController:con animated:YES];
		[con release];
	}
	else if (indexPath.row == 1) {
		AppWeeklyViewController *con = [[AppWeeklyViewController alloc] initWithStyle:UITableViewStylePlain];
		con.currentSales = sales;
		[self.navigationController pushViewController:con animated:YES];
		[con release];
	}
	else if (indexPath.row == 2) {
		AppCountriesViewController *con = [[AppCountriesViewController alloc] initWithStyle:UITableViewStylePlain];
		con.currentSales = sales;
		[self.navigationController pushViewController:con animated:YES];
		[con release];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationItem.title = sales.info.name;
}

- (id)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	return self;
}

- (void)dealloc {
	[sales release];
    [super dealloc];
}

@end

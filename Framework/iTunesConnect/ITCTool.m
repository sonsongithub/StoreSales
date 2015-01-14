//
//  ITCTool.m
//  StoreSales
//
//  Created by sonson on 09/05/27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ITCTool.h"
#import "SQLiteDBController.h"

NSString *kITCBaseURL = @"https://itts.apple.com";

NSString* postFrmVendorPageActionFromHTML(NSString* html) {
	//
	// Extract base URL fragment for ?????
	// For example:
	// /cgi-bin/WebObjects/Piano.woa/2/wo/TYbknplpGbWx3E6BAs0tDM/2.9
	//
	// <form method="post" action="
	NSString *prefix = @"name=\"frmVendorPage\" action=\"";
	NSString *suffix = @"\">";
	NSScanner *scanner = [NSScanner scannerWithString:html];
	NSString *postFrmVendorPageAction = nil;
	if ([scanner scanUpToString:prefix intoString:nil]) {
	}
	if ([scanner scanString:prefix intoString:nil]) {
	}
	if ([scanner scanUpToString:suffix intoString:&postFrmVendorPageAction]) {
	}
	return postFrmVendorPageAction;
}

#if TARGET_OS_IPHONE

#else

void showAlertWithMessage(NSString* message) {
	NSAlert* alert =[NSAlert alertWithMessageText:NSLocalizedString(@"Error", nil)
									defaultButton:NSLocalizedString(@"OK", nil)
								  alternateButton:nil
									  otherButton:nil
						informativeTextWithFormat:message];
	[alert runModal];
}

#endif

//
// iTunes connect symbol
//
NSString *summarySymbol = @"19.11";
NSString *weeklySymbol = @"19.13";
NSString *dailySymbol = @"19.13";
NSString *weeklySelectName = @"19.17.1";
NSString *dailySelectName = @"19.15.1";
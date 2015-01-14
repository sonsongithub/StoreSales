//
//  ITCTool.h
//  StoreSales
//
//  Created by sonson on 09/05/27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// For parsing tool iTunes connect sales log
//
#import "ITCLogParser.h"

//
// Base URL for access to iTunes connect
//
extern NSString *kITCBaseURL;

//
// Extract base URL fragment for ?????
// For example:
// /cgi-bin/WebObjects/Piano.woa/2/wo/TYbknplpGbWx3E6BAs0tDM/2.9
//
NSString* postFrmVendorPageActionFromHTML(NSString* html);

#if TARGET_OS_IPHONE
#else
void showAlertWithMessage(NSString* message);
#endif

//
// iTunes connect symbol
//
extern NSString *summarySymbol;
extern NSString *weeklySymbol;
extern NSString *dailySymbol;
extern NSString *weeklySelectName;
extern NSString *dailySelectName;
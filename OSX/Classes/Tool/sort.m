//
//  sort.m
//  StoreSales
//
//  Created by sonson on 09/10/04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "sort.h"

int ApplicationSalesSort(id val1, id val2, void *context) {
	if (((ApplicationSales*)val1).value > ((ApplicationSales*)val2).value)
		return NSOrderedAscending;
	else if (((ApplicationSales*)val1).value < ((ApplicationSales*)val2).value)
		return  NSOrderedDescending;
	else return NSOrderedSame;
}

int CountrySalesSort(id val1, id val2, void *context) {
	if (((CountrySales*)val1).value > ((CountrySales*)val2).value)
		return NSOrderedAscending;
	else if (((CountrySales*)val1).value < ((CountrySales*)val2).value)
		return  NSOrderedDescending;
	else return NSOrderedSame;
}
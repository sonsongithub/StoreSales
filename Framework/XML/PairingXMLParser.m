//
//  PairingXMLParser.m
//  StoreSalesClient
//
//  Created by sonson on 09/05/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PairingXMLParser.h"

@implementation PairingXMLParser

@synthesize dictionary, currentElementName, currentString;

- (void)parse:(NSData*)data {
	NSXMLParser *parse = [[NSXMLParser alloc] initWithData:data];
	parse.delegate = self;
	self.dictionary = [NSMutableDictionary dictionary];
	[parse parse];
	[parse release];
}

- (void)dump {
	for (NSString *key in [self.dictionary allKeys]) {
		NSLog(@"%@ - %@", key, [self.dictionary objectForKey:key]);
	}
}

#pragma mark -
#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	self.currentElementName = elementName;
	self.currentString = [NSMutableString string];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[self.currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if( self.currentElementName && self.currentString && [self.currentString length] > 0 ) {
		[self.dictionary setObject:self.currentString forKey:self.currentElementName];
	}
	self.currentElementName = nil;
	self.currentString = nil;
}

#pragma mark -
#pragma mark Override

- (id)init {
	self = [super init];
	return self;
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[dictionary release];
	[super dealloc];
}

@end

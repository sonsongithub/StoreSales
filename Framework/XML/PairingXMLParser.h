//
//  PairingXMLParser.h
//  StoreSalesClient
//
//  Created by sonson on 09/05/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	PairingSuccess = 0,
	PairingPasscodeWrong = 1,
	PairingUnknownError = 2
}PairingResultCode;

@interface PairingXMLParser : NSObject
#if TARGET_OS_IPHONE	// a couple of protocols are not implemented on MacOSX
<NSXMLParserDelegate>
#else
<NSXMLParserDelegate>
#endif
{
	NSMutableDictionary *dictionary;
	NSString			*currentElementName;
	NSMutableString		*currentString;
}
@property (nonatomic, retain) NSMutableDictionary	*dictionary;
@property (nonatomic, retain) NSString				*currentElementName;
@property (nonatomic, retain) NSMutableString		*currentString;
- (void)parse:(NSData*)data;
- (void)dump;
@end

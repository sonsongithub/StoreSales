//
//  FileSendXMLMaker.h
//  StoreSales
//
//  Created by sonson on 09/06/03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileSendXMLMaker : NSObject {
}
+ (NSData*)XMLToSendData:(NSData*)data filepath:(NSString*)path remained:(int)remained already:(int)already;
+ (NSData*)XMLToSendRequestOK;
+ (NSData*)XMLToSendAuthorizationFailed;
+ (NSData*)XMLToSendTaskFinished;
@end

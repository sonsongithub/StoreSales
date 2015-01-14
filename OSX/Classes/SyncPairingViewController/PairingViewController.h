#import <UIKit/UIKit.h>
#import "BonjourServer.h"

#define kBonjourIdentifier @"StoreSalesPairing"

@interface PairingViewController : UIViewController <StreamManagerDelegate>{
    IBOutlet UITextView	*description;
    IBOutlet UILabel	*digit0;
    IBOutlet UILabel	*digit1;
    IBOutlet UILabel	*digit2;
    IBOutlet UILabel	*digit3;
    IBOutlet UILabel	*passcodeLabel;
    IBOutlet UIImageView *digiti0image;
    IBOutlet UIImageView *digiti1image;
    IBOutlet UIImageView *digiti2image;
    IBOutlet UIImageView *digiti3image;
	
	NSMutableArray		*passcodeDigits;
	NSString			*passcodeString;
	
	BonjourServer		*server;	
	NSInputStream		*inStream;
	NSOutputStream		*outStream;
	
	NSString			*ownName;
	NSString			*targetName;
}
@property (nonatomic, retain) NSMutableArray *passcodeDigits;
@property (nonatomic, retain) NSString *passcodeString;
@property (nonatomic, retain) BonjourServer *server;
@property (nonatomic, retain) NSString *ownName;
@property (nonatomic, retain) NSString *targetName;
@property (nonatomic, retain) NSInputStream *inStream;
@property (nonatomic, retain) NSOutputStream *outStream;

#pragma mark -
#pragma mark UI
- (void)updatePasscode;
#pragma mark -
#pragma mark XML Maker
- (NSData*)successedXML;
- (NSData*)failedXMLWithErrorCode:(int)errorCode errorMessage:(NSString*)errorMessage;
#pragma mark -
#pragma mark XML Handler
- (void)checkXML:(NSData*)data;
#pragma mark -
#pragma mark Send
- (void)sendDataWithEncryptionWithFixedKey:(NSData*)data;

@end

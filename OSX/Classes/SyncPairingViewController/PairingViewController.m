#import "PairingViewController.h"
#import <stdlib.h>
#import <time.h>
#import "PairingXMLParser.h"
#import "NSString+digest.h"
#import "UICNSData+AES256.h"
#import <Security/Security.h>
#import "BonjourServer.h"

@implementation PairingViewController

@synthesize passcodeDigits, passcodeString, server, targetName, ownName, inStream, outStream;

#pragma mark -
#pragma mark UI

- (void)updatePasscode {
	uint16_t randomized_code = 0;
	//
	// Make random 4 digits number which is used as passcode 
	// 
#if TARGET_IPHONE_SIMULATOR
	//
	// On iPhone Simulator, SecRandomCopyBytes has not been implemented.
	//
	randomized_code = 0;
#else
	SecRandomCopyBytes(kSecRandomDefault, sizeof(randomized_code), (uint8_t*)&randomized_code);
#endif
	
	// make NSString based on random 4 digits number
	self.passcodeString = [NSString stringWithFormat:@"%04d", randomized_code % 10000];
	
	// set passcode into UI
	self.passcodeDigits = [NSMutableArray array];
	[self.passcodeDigits addObject:[self.passcodeString substringWithRange:NSMakeRange(0, 1)]];
	[self.passcodeDigits addObject:[self.passcodeString substringWithRange:NSMakeRange(1, 1)]];
	[self.passcodeDigits addObject:[self.passcodeString substringWithRange:NSMakeRange(2, 1)]];
	[self.passcodeDigits addObject:[self.passcodeString substringWithRange:NSMakeRange(3, 1)]];
	
	digit0.text = [self.passcodeDigits objectAtIndex:0];
	digit1.text = [self.passcodeDigits objectAtIndex:1];
	digit2.text = [self.passcodeDigits objectAtIndex:2];
	digit3.text = [self.passcodeDigits objectAtIndex:3];
}

#pragma mark -
#pragma mark XML Maker

- (NSData*)successedXML {
	//
	// Make XML which includes UDID and iPhone's device name
	//
	UIDevice *device = [UIDevice currentDevice];
	NSString *u_identifier = [device uniqueIdentifier];
	NSString *identifier = [u_identifier MD5DigestString];
	NSMutableString *xml = [NSMutableString string];
	[xml appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
	[xml appendString:@"<StoreSalesPairing>"];
	[xml appendFormat:@"<result>OK</result>"];
	[xml appendFormat:@"<iphone>%@</iphone>", [BonjourServer serverName]];
	[xml appendFormat:@"<udid>%@</udid>", identifier];
	[xml appendString:@"</StoreSalesPairing>"];
	return [xml dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData*)failedXMLWithErrorCode:(int)errorCode errorMessage:(NSString*)errorMessage {
	//
	// Make XML which means some error was happend during processing
	//
	NSMutableString *xml = [NSMutableString string];
	[xml appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
	[xml appendString:@"<StoreSalesPairing>"];
	[xml appendFormat:@"<error>%d</error>", errorCode];
	[xml appendFormat:@"<error_message>%@</error_message>", errorMessage];
	[xml appendString:@"</StoreSalesPairing>"];
	return [xml dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark -
#pragma mark XML Handler

- (void)checkXML:(NSData*)data {
	DNSLogMethod
	//
	// Parse and dispatch when xml is received
	//
	NSData *decryptedData = [data dataDecryptedWithKey:@"d38jslajd8d"];
	PairingXMLParser* parser = [[PairingXMLParser alloc] init];
	[parser parse:decryptedData];
//	[parser dump];
	//
	// Check
	//
	if ([parser.dictionary objectForKey:@"challenge"]) {
		//
		// Check passcode which is sent from remote Mac
		//
		if ([self.passcodeString isEqualToString:[parser.dictionary objectForKey:@"challenge"]]) {
			//
			// Save macname and passcode into Userdefaults
			//
			NSString *macname = [parser.dictionary objectForKey:@"macname"];
			[[NSUserDefaults standardUserDefaults] setObject:macname forKey:@"macname"];
			[[NSUserDefaults standardUserDefaults] setObject:passcodeString forKey:@"passcode"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			//
			// Send XML which means that passcode check is successed.
			//
			NSData *data = [self successedXML];
			[self sendDataWithEncryptionWithFixedKey:data];
		}
		else {
			//
			// Paacode is wrong, so send XML which passcode check is failed.
			//
			NSData *data = [self failedXMLWithErrorCode:PairingPasscodeWrong errorMessage:@"Passcode is wrong"];
			[self sendDataWithEncryptionWithFixedKey:data];
		}
	}
	else if ([[parser.dictionary objectForKey:@"pairingResult"] isEqualToString:@"success"]) {
		//
		// Received XML which means that pairing is successed
		//
	}
	else {
		//
		// Received XML which means some error is happened.
		//
		NSData *data = [self failedXMLWithErrorCode:PairingUnknownError errorMessage:@"Unknown error"];
		[self sendDataWithEncryptionWithFixedKey:data];
		//
		// Restart Bonjour server which received pairing socket
		//
		[server startServer];
	}
		
	[parser release];
}

#pragma mark -
#pragma mark Send

- (void)sendDataWithEncryptionWithFixedKey:(NSData*)data {
	DNSLogMethod
	NSData *encryptedData = [data dataEncryptedWithKey:@"d38jslajd8d"];
	[server sendData:encryptedData];
}

#pragma mark -
#pragma mark BonjourServerDelegate

- (void)openCompletedStream:(NSStream*)stream {
}

- (void)endEncounteredStream:(NSStream*)stream {
	DNSLogMethod
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)receivedData:(NSData*)data stream:(NSStream*)stream {
	DNSLogMethod
	[self checkXML:data];
}

#pragma mark -
#pragma mark override

- (id)init {
	DNSLogMethod
	self = [super initWithNibName:@"PairingViewController" bundle:nil];
	
	self.server = [[[BonjourServer alloc] init] autorelease];
	[self.server setDelegate:self];
	self.server.serviceType = [TCPServer bonjourTypeFromIdentifier:kBonjourIdentifier];
	
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	//
	// for iPhone 2.2.1 xib, set strechable image
	//
	UIImage *croppedImage = [digiti0image.image stretchableImageWithLeftCapWidth:13 topCapHeight:13];
	digiti0image.image = croppedImage;
	digiti1image.image = croppedImage;
	digiti2image.image = croppedImage;
	digiti3image.image = croppedImage;
	[self updatePasscode];
	
	description.font = [UIFont systemFontOfSize:14];
	
	//
	// Update message
	//
	passcodeLabel.text = NSLocalizedString(@"Passcode", nil);
	NSString *server_name = [BonjourServer serverName];
	if (server_name == nil)
		server_name = NSLocalizedString(@"this iPhone's name", nil);
	NSString *mes = [NSString stringWithFormat:NSLocalizedString(@"For paring with Your Mac", nil), server_name];
	description.text = mes;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.title = NSLocalizedString(@"Pairing", nil);
	[server startServer];
}

- (void)viewWillDisappear:(BOOL)animated {
	DNSLogMethod
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	DNSLogMethod
	server.delegate = nil;
	[server stopServer];
	[server closeStreams];
	[server release];
	[passcodeDigits release];
	[passcodeString release];
    [super dealloc];
}

@end

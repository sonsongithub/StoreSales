
#import <Foundation/Foundation.h>

@class TCPServerController;

NSString * const TCPServerControllerErrorDomain;

typedef enum {
    kTCPServerControllerCouldNotBindToIPv4Address = 1,
    kTCPServerControllerCouldNotBindToIPv6Address = 2,
    kTCPServerControllerNoSocketsAvailable = 3,
} TCPServerControllerErrorCode;

@protocol TCPServerControllerDelegate <NSObject>
@optional
- (void)openCompletedStream:(NSStream*)stream;
- (void)endEncounteredStream:(NSStream*)stream;
- (void) serverDidEnableBonjour:(TCPServerController*)server withName:(NSString*)name;
- (void) server:(TCPServerController*)server didNotEnableBonjour:(NSDictionary *)errorDict;
- (void) didAcceptConnectionForServer:(TCPServerController*)server inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr;
- (void)stream:(NSStream*)stream handleEvent:(NSStreamEvent)eventCode;
@end

@interface TCPServerController : NSObject
#if TARGET_OS_IPHONE	// a couple of protocols are not implemented on MacOSX
<NSStreamDelegate, NSNetServiceDelegate>
#else
<NSStreamDelegate, NSNetServiceDelegate>
#endif
{
	id				_delegate;
    uint16_t		_port;
	CFSocketRef		_ipv4socket;
	NSNetService	*_netService;
	
	NSInputStream	*inStream;
	NSOutputStream	*outStream;
	
	NSString		*ownName;
}
@property (nonatomic, retain) NSInputStream *inStream;
@property (nonatomic, retain) NSOutputStream *outStream;
@property (nonatomic, retain) NSString *ownName;

@property(assign) id<TCPServerControllerDelegate> delegate;

#pragma mark -
#pragma mark Class method
+ (NSString*)bonjourTypeFromIdentifier:(NSString*)identifier;
+ (NSString*)serverName;

#pragma mark -
#pragma mark Instance method
- (BOOL)stop;
- (void)stopAllStreams;
- (void)disableBonjour;

@end

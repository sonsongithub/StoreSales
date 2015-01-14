
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <CoreFoundation/CoreFoundation.h>

#if TARGET_OS_IPHONE
	#include <CFNetwork/CFSocketStream.h>
	#include <CFNetwork/CFNetwork.h>
#else
	// MACOSX
#endif

#import "TCPServerController.h"

NSString * const TCPServerControllerErrorDomain = @"TCPServerControllerErrorDomain";

@interface TCPServerController ()
@property(nonatomic,retain) NSNetService* netService;
@property(assign) uint16_t port;
@end

NSString* serverName = nil;

@implementation TCPServerController

@synthesize delegate=_delegate, netService=_netService, port=_port;
@synthesize inStream, outStream, ownName;

#pragma mark -
#pragma mark Class method

+ (NSString*)bonjourTypeFromIdentifier:(NSString*)identifier {
	if (![identifier length])
		return nil;
    return [NSString stringWithFormat:@"_%@._tcp.", identifier];
}

+ (NSString*)serverName {
	return serverName;
}


#pragma mark -
#pragma mark Instance method

- (BOOL)stop {
    [self disableBonjour];
	
	if (_ipv4socket) {
		CFSocketInvalidate(_ipv4socket);
		CFRelease(_ipv4socket);
		_ipv4socket = NULL;
	}
	
	[self stopAllStreams];
	
    return YES;
}

- (void)stopAllStreams {
	[inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[inStream close];
	self.inStream.delegate = nil;
	self.inStream = nil;
	
	[outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outStream close];
	self.outStream.delegate = nil;
	self.outStream = nil;
}

- (void) disableBonjour {
	if(self.netService) {
		[self.netService stop];
		[self.netService removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		self.netService = nil;
	}
}

#pragma mark -
#pragma mark TCP/Server

- (void)handleNewConnectionFromAddress:(NSData *)addr inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr {
	DNSLogMethod
	if (inStream || outStream) {
		DNSLog(@"Already streams are connected");
		return;
	}
	
	self.inStream = istr;
	self.outStream = ostr;
	
	inStream.delegate = self;
	[inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[inStream open];
	
	outStream.delegate = self;
	[outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outStream open];
	
    if (self.delegate && [self.delegate respondsToSelector:@selector(didAcceptConnectionForServer:inputStream:outputStream:)]) { 
        [self.delegate didAcceptConnectionForServer:self inputStream:istr outputStream:ostr];
    }
}

static void TCPServerAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    TCPServerController *server = (TCPServerController *)info;
    if (kCFSocketAcceptCallBack == type) { 
        // for an AcceptCallBack, the data parameter is a pointer to a CFSocketNativeHandle
        CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;
        uint8_t name[SOCK_MAXADDRLEN];
        socklen_t namelen = sizeof(name);
        NSData *peer = nil;
        if (0 == getpeername(nativeSocketHandle, (struct sockaddr *)name, &namelen)) {
            peer = [NSData dataWithBytes:name length:namelen];
        }
        CFReadStreamRef readStream = NULL;
		CFWriteStreamRef writeStream = NULL;
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle, &readStream, &writeStream);
        if (readStream && writeStream) {
            CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            [server handleNewConnectionFromAddress:peer inputStream:(NSInputStream *)readStream outputStream:(NSOutputStream *)writeStream];
        } else {
            // on any failure, need to destroy the CFSocketNativeHandle 
            // since we are not going to use it any more
            close(nativeSocketHandle);
        }
        if (readStream) CFRelease(readStream);
        if (writeStream) CFRelease(writeStream);
    }
}

- (BOOL)start:(NSError **)error {
    CFSocketContext socketCtxt = {0, self, NULL, NULL, NULL};
    _ipv4socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)&TCPServerAcceptCallBack, &socketCtxt);
	
    if (NULL == _ipv4socket) {
        if (error) *error = [[NSError alloc] initWithDomain:TCPServerControllerErrorDomain code:kTCPServerControllerNoSocketsAvailable userInfo:nil];
        if (_ipv4socket) CFRelease(_ipv4socket);
        _ipv4socket = NULL;
        return NO;
    }
	
    int yes = 1;
    setsockopt(CFSocketGetNative(_ipv4socket), SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
	
    // set up the IPv4 endpoint; use port 0, so the kernel will choose an arbitrary port for us, which will be advertised using Bonjour
    struct sockaddr_in addr4;
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_port = 0;
    addr4.sin_addr.s_addr = htonl(INADDR_ANY);
    NSData *address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];
	
    if (kCFSocketSuccess != CFSocketSetAddress(_ipv4socket, (CFDataRef)address4)) {
        if (error) *error = [[NSError alloc] initWithDomain:TCPServerControllerErrorDomain code:kTCPServerControllerCouldNotBindToIPv4Address userInfo:nil];
        if (_ipv4socket) CFRelease(_ipv4socket);
        _ipv4socket = NULL;
        return NO;
    }
    
	// now that the binding was successful, we get the port number 
	// -- we will need it for the NSNetService
	NSData *addr = [(NSData *)CFSocketCopyAddress(_ipv4socket) autorelease];
	memcpy(&addr4, [addr bytes], [addr length]);
	self.port = ntohs(addr4.sin_port);
	
    // set up the run loop sources for the sockets
    CFRunLoopRef cfrl = CFRunLoopGetCurrent();
    CFRunLoopSourceRef source4 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _ipv4socket, 0);
    CFRunLoopAddSource(cfrl, source4, kCFRunLoopCommonModes);
    CFRelease(source4);
	
    return YES;
}

- (BOOL)enableBonjourWithDomain:(NSString*)domain applicationProtocol:(NSString*)protocol name:(NSString*)name {
	if(![domain length])
		domain = @""; //Will use default Bonjour registration doamins, typically just ".local"
	if(![name length])
		name = @""; //Will use default Bonjour name, e.g. the name assigned to the device in iTunes
	
	if(!protocol || ![protocol length] || _ipv4socket == NULL)
		return NO;
	
	self.netService = [[NSNetService alloc] initWithDomain:domain type:protocol name:name port:self.port];
	if(self.netService == nil)
		return NO;
	
	[self.netService scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[self.netService publish];
	[self.netService setDelegate:self];
	
	return YES;
}

#pragma mark -
#pragma mark NSNetServiceDelegate

- (void)netServiceDidPublish:(NSNetService *)sender {
	[serverName release];
	serverName = [sender.name retain];
    if (self.delegate && [self.delegate respondsToSelector:@selector(serverDidEnableBonjour:withName:)])
		[self.delegate serverDidEnableBonjour:self withName:sender.name];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
	[self netServiceDidPublish:sender];
	if(self.delegate && [self.delegate respondsToSelector:@selector(server:didNotEnableBonjour:)])
		[self.delegate server:self didNotEnableBonjour:errorDict];
}

#pragma mark -
#pragma mark StreamDelegate

- (void)stream:(NSStream*)stream handleEvent:(NSStreamEvent)eventCode {
	DNSLogMethod
	switch(eventCode) {
		case NSStreamEventOpenCompleted:
			DNSLog(@"NSStreamEventOpenCompleted");
			break;
		case NSStreamEventHasBytesAvailable:
			DNSLog(@"NSStreamEventHasBytesAvailable");
			break;
		case NSStreamEventEndEncountered:
			DNSLog(@"NSStreamEventEndEncountered");
			break;
	}
	
	if ([self.delegate respondsToSelector:@selector(stream:handleEvent:)]) {
		[self.delegate stream:stream handleEvent:eventCode];
	}
	
	if (eventCode == NSStreamEventOpenCompleted) {
		// established stream
		if ([self.delegate respondsToSelector:@selector(openCompletedStream:)]) {
			[self.delegate openCompletedStream:stream];
		}
	}
	else if (eventCode == NSStreamEventEndEncountered) {
		if ([self.delegate respondsToSelector:@selector(endEncounteredStream:)]) {
			[self.delegate endEncounteredStream:stream];
		}
		[self stopAllStreams];
	}
}

#pragma mark -
#pragma mark Override

- (id)init {
	self = [super init];
    return self;
}

- (NSString*)description {
	return [NSString stringWithFormat:@"<%@ = 0x%08X | port %d | netService = %@>", [self class], (long)self, self.port, self.netService];
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	DNSLogMethod
	[self stopAllStreams];
	
	[self disableBonjour];
	[self stop];
	
	[ownName release];
    [self stop];
    [super dealloc];
}

@end

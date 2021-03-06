#import <CoreFoundation/CoreFoundation.h>


@interface NSDictionary (HTTPExtensions)

- (NSString *)formatForHTTP;
- (NSString *)formatForHTTPUsingEncoding:(NSStringEncoding)inEncoding;
- (NSString *)formatForHTTPUsingEncoding:(NSStringEncoding)inEncoding ordering:(NSArray *)inOrdering;

@end

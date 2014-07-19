
@interface JSDieException : NSException

+ (NSString *)name;
+ (JSDieException *)exceptionWithMessage:(NSString *)message;
+ (JSDieException *)exceptionWithFormat:(NSString *)format, ...;

@end

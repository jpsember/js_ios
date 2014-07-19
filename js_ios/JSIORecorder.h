#if DEBUG

@interface JSIORecorder : NSObject

+ (JSIORecorder *)start;
+ (JSIORecorder *)start:(BOOL)replaceIfChanged;
+ (JSIORecorder *)startWithClassName:(NSString *)c methodName:(NSString *)m replaceIfChanged:(BOOL)r;
+ (void)stop;

/*
 The name of exceptions thrown by the JSIORecorder API
 */
+ (NSString *)exceptionName;

@end

#endif
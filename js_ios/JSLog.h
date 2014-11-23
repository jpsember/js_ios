#if DEBUG

@protocol JSAppendStringProtocol;

@interface JSLog : NSObject

+ (void)flushLog;
+ (void)logString:(NSString *)string;
+ (void)pushLogHandler:(id<JSAppendStringProtocol>)handler;
+ (void)popLogHandler;
@end

#endif

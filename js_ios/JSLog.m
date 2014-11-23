#import "JSBase.h"
#import "JSLog.h"

#if DEBUG

#if DEBUG

#import "JSAppendStringProtocol.h"

static dispatch_queue_t printerQueue;
static NSMutableArray *printHandlerStack;
static id<JSAppendStringProtocol> activeLogHandler;
static id defaultLogHandler;

@interface DefaultLogHandler: NSObject<JSAppendStringProtocol>
@end

@implementation DefaultLogHandler
- (void)appendString:(NSString *)string {
  fputs([string UTF8String], stdout);
}
@end

#endif

@implementation JSLog

#if DEBUG
+ (void)load {
  printHandlerStack = [NSMutableArray array];
  printerQueue = dispatch_queue_create("DebugUtil.printerQueue",DISPATCH_QUEUE_SERIAL);
  defaultLogHandler =[[DefaultLogHandler alloc] init];
  [self pushLogHandler:defaultLogHandler];
}

#endif


+ (void)logString:(NSString *)string {
  ASSERT(string,@"attempt to log nil string");
  dispatch_async(printerQueue,^{
    [activeLogHandler appendString:string];
  });
  [self flushLog];
}

+ (void)flushLog {
  // This is only safe if we're in the main thread; or, specifically,
  // if we're not already in the printerQueue thread.
  if ([NSThread mainThread])
    dispatch_sync(printerQueue,^{});
}

+ (void)pushLogHandler:(id<JSAppendStringProtocol>)handler {
  dispatch_async(printerQueue,^{
    [printHandlerStack addObject:handler];
    activeLogHandler = handler;
  });
  [self flushLog];
}

+ (void)popLogHandler {
  dispatch_async(printerQueue,^{
    [printHandlerStack removeLastObject];
    activeLogHandler = [printHandlerStack lastObject];
  });
  [self flushLog];
}

@end

#endif

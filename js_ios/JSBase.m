#import <execinfo.h>
#import <objc/runtime.h>
#import "JSBase.h"
#if DEBUG
#import "JSStackTraceElement.h"
#import "JSSymbolicNames.h"
#endif

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


@implementation JSBase

#if DEBUG
+ (void)load {
  printHandlerStack = [NSMutableArray array];
  printerQueue = dispatch_queue_create("DebugUtil.printerQueue",DISPATCH_QUEUE_SERIAL);
  defaultLogHandler =[[DefaultLogHandler alloc] init];
  [self pushLogHandler:defaultLogHandler];
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
#endif

+ (void)dieWithMessage:(NSString *)message {
  JSDieException *e = [JSDieException exceptionWithMessage:message];
  DBG
  IFDBG(
        if (![JSBase testModeActive]) {
          warning(@"DBG is true in dieWithMessage, this is normally false");
          printf("dying with %s\n",[[e description] UTF8String]);
          [self breakpoint];
        }
        );
  @throw e;
}


+ (BOOL)testModeActive {
  static BOOL active;
  ONCE_ONLY(^{
    // It can't find JSTestAppDelegate, now that it's a .swift file
    active = objc_lookUpClass("JSBaseTests") != nil;
    DBG
    pr(@"active=%d\n",active);
  });
  return active;
}

#if DEBUG

+ (void)showTimeStamp:(NSString *)format, ... {
  static double startTime = 0;
  static double prevTime = 0;
  double t = CACurrentMediaTime();
  if (!prevTime) {
    prevTime = t;
    startTime = t;
  }
  double el = t - prevTime;
  prevTime = t;
  
  bool ignoreElapsed = false;
  if ([format hasPrefix:@"!"]) {
    ignoreElapsed = YES;
    format = [format substringFromIndex:1];
  }
  va_list vl;
  va_start(vl, format);
  NSString *s = [[NSString alloc] initWithFormat:format arguments:vl];
  va_end(vl);
  
  NSString *work = nil;
  DBG
  if (!ignoreElapsed && el > 0.1f) {
    work = [NSString stringWithFormat:@"%5.2f",el];
  } else {
    work = @"     ";
  }
  pr(@"%@ %5.2f : %@\n",work,t-startTime,s);
}


+ (NSString *)descriptionForPath:(NSString *)path lineNumber:(int)lineNumber {
  return [NSString stringWithFormat:@"(%@:%d)",[path lastPathComponent],lineNumber];
}

+ (void)log:(NSString *)format, ... {
  va_list vl;
  va_start(vl, format);
  NSString* str = [[NSString alloc] initWithFormat:format arguments:vl];
  va_end(vl);
  [JSBase logString:str];
}

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

+ (void)breakpoint {
  [self flushLog];
  // DBG
  pr(@"(Breakpoint...)\n");
  [self sleepFor:.2];
  pr(@"\n");
}

+ (NSString *)stackTraceString:(int)skipElements0 max:(int)maxElements {
  NSArray *array = [self stackTrace];
  
  NSMutableString *s = [NSMutableString stringWithString:@""];
  
  int skipElements = skipElements0 + 2;
  
  int iStop = MIN(skipElements + maxElements, (int)array.count);
  for (int i = skipElements; i < iStop; i++) {
    NSString *s2 = [NSString stringWithFormat:@"%-44s ",[[array[i] description] UTF8String]];
    [s appendString:s2];
  }
  return s;
}

+ (NSMutableArray *)stackTrace {
  NSMutableArray *parsedElements = [NSMutableArray array];
  
  int maxElements = 10;
  void *array[maxElements];
  int nElements = backtrace(array,maxElements);
  char **bs = backtrace_symbols(array,nElements);
  for (int i = 0; i < nElements; i++) {
    NSString *s = [NSString stringWithUTF8String:bs[i]];
    JSStackTraceElement *elem = [JSStackTraceElement parse:s];
    if (elem)
      [parsedElements addObject:elem];
  }
  free(bs);
  return parsedElements;
}

+ (void)oneTimeReport:(NSString *)fileAndLine message:(NSString *)message reportType:(NSString *)reportType {
  static NSMutableSet *reportsMade;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    reportsMade = [NSMutableSet set];
  });
  NSString *reportText = [NSString stringWithFormat:@"*** %@ %@: %@\n",reportType,fileAndLine,message];
  if (![reportsMade containsObject:reportText]) {
    [reportsMade addObject:reportText];
    [JSBase logString:reportText];
  }
}

static JSSymbolicNames *names;

+ (NSString *)symbolicNameForId:(id)object {
  if (!object) return @"null";
  
  return [self symbolicNameForPtr:(__bridge void *)object];
}

+ (NSString *)symbolicNameForPtr:(const void *)ptr {
  
  @synchronized([self class]) {
    if (!names) {
      names = [[JSSymbolicNames alloc] init];
    }
    return [names nameFor:ptr];
  }
}

+ (void)resetSymbolicPtrNames {
  @synchronized([self class]) {
    names = nil;
  }
}

+ (void)sleepFor:(float)timeInSeconds {
  [NSThread sleepForTimeInterval: timeInSeconds];
}

#endif // DEBUG

+ (NSString *)stringFromBool:(BOOL)b {
  return b ? @"Y" : @"N";
}

+ (NSString *)dumpBits:(uint)value {
  NSMutableString *s = [NSMutableString string];
  BOOL bitPrinted = NO;
  for (int bitNumber = 32-1; bitNumber >= 0; bitNumber--) {
    BOOL bit = (value & (1 << bitNumber)) != 0;
    if (bit || bitNumber == 4-1) {
      bitPrinted = YES;
    }
    if (bitPrinted) {
      [s appendString: bit ? @"1" : @"."];
      if (bitNumber != 0 && bitNumber % 4 == 0) {
        [s appendString:@" "];
      }
    }
  }
  return s;
}

+ (void)dieWithFilename:(const char *)filename line:(int)line
{
  NSString *message = [NSString stringWithFormat:@"*** fatal error: (%s:%d)",filename,line];
  [JSBase dieWithMessage:message];
}

@end

#if DEBUG
bool _DEBUG_PRINTING_ = NO;

@interface Inf()
@property (nonatomic, strong) NSString *ourDescription;
@property (nonatomic, assign) int iteration;
@property (nonatomic, assign) int maxIterations;
@end

@implementation Inf

- (instancetype)initWithDescription:(NSString *)description maxIterations:(int)maxIter {
  if (self = [super init]) {
    _ourDescription = description;
    _maxIterations = maxIter;
  }
  return self;
}

- (void)update {
  _iteration++;
  if (_iteration == _maxIterations) {
    die(@"Infinite loop detected (%@); iterations=%d",_ourDescription,_iteration);
  }
}

@end
#endif

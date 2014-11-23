#import <objc/runtime.h>
#import "JSBase.h"
#if DEBUG
#import "JSLog.h"
#import "JSSymbolicNames.h"
#endif



@implementation JSBase

+ (void)dieWithMessage:(NSString *)message {
  JSDieException *e = [JSDieException exceptionWithMessage:message];
  @throw e;
}

+ (BOOL)testModeActive {
  static BOOL active;
  ONCE_ONLY(^{
    // It can't find JSTestAppDelegate, now that it's a .swift file
    active = objc_lookUpClass("JSBaseTests") != nil;
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

+ (void)logString:(NSString *)string {
  [JSLog logString:string];
}

+ (void)log:(NSString *)format, ... {
  va_list vl;
  va_start(vl, format);
  NSString* str = [[NSString alloc] initWithFormat:format arguments:vl];
  va_end(vl);
  [JSLog logString:str];
}

+ (void)breakpoint {
  [JSLog flushLog];
  // DBG
  pr(@"(Breakpoint...)\n");
  [self sleepFor:.2];
  pr(@"\n");
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

+ (void)exitApp {
  exit(0);
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

+ (void)dieWithFilename:(const char *)filename line:(int)line
{
  NSString *message = [NSString stringWithFormat:@"*** fatal error: (%s:%d)",filename,line];
  [JSBase dieWithMessage:message];
}

@end

#if DEBUG
bool _DEBUG_PRINTING_ = NO;
#endif

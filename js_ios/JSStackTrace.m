#import <execinfo.h>
#import "JSStackTrace.h"

@interface JSStackTraceElement : NSObject
@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *methodType;
@property (nonatomic, strong) NSString *methodName;
@property (nonatomic, assign) int lineNumber;

+ (JSStackTraceElement *)parse:(NSString *)string;
@end

@implementation JSStackTraceElement

+ (JSStackTraceElement *)parse:(NSString *)s {
    
    JSStackTraceElement *ret = nil;
    JSStackTraceElement *ret2 = [[JSStackTraceElement alloc] init];
    
    int p1 = [s indexOf:@"["];
    int p2 = [s indexOf:@"]"];
    do {
        if (p1 < 1 || p2 < p1) break;
        ret2.methodType = [s substringWithRange:NSMakeRange(p1-1,1)];
        NSString *invocation = [s substringWithRange:NSMakeRange(p1+1,p2-p1-1)];
        int sp = [invocation indexOf:@" "];
        if (sp < 1) break;
        ret2.className = [invocation substringToIndex:sp];
        ret2.methodName = [invocation substringFromIndex:1+sp];
        int lnNumberPos = [s indexOf:@" + "];
        if (lnNumberPos < p2) break;
        NSString *lineNumber = [s substringFromIndex:lnNumberPos+3];
        ret2.lineNumber = [lineNumber intValue];
        ret = ret2;
    } while (false);
    return ret;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"(%@ %@)",_className,_methodName];
}

@end

@implementation JSStackTrace

+ (NSString *)stackTraceString:(int)skipElements0 max:(int)maxElements {
  NSArray *array = [JSStackTrace stackTrace];

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

+ (NSArray *)extractClassAndMethodNames {
  NSArray *stackTrace = [JSStackTrace stackTrace];
  JSStackTraceElement *callerElem = nil;
  for (JSStackTraceElement *elem in stackTrace) {
    if ([elem.methodName hasPrefix:@"test"]) {
      callerElem = elem;
      break;
    }
  }
  if (!callerElem)
  die(@"no test methods found in stack trace: %@",stackTrace);
  NSMutableArray *array = [NSMutableArray array];
  NSString *className = callerElem.className;
  NSString *mth = callerElem.methodName;
  NSString *methodName = [mth stringByReplacingOccurrencesOfString:@":" withString:@"_"];
  [array addObject:className];
  [array addObject:methodName];
  return array;
}

+ (NSArray *)callerWithMethodNamePrefix:(NSString *)prefix {
  NSArray *stackTrace = [JSStackTrace stackTrace];
  JSStackTraceElement *callerElem = nil;
  for (JSStackTraceElement *elem in stackTrace) {
    if ([elem.methodName hasPrefix:prefix]) {
      callerElem = elem;
      break;
    }
  }

  if (!callerElem)
    return nil;
  NSString *className = callerElem.className;
  NSString *methodName = [callerElem.methodName stringByReplacingOccurrencesOfString:@":" withString:@"_"];
  return @[className, methodName];
}

@end

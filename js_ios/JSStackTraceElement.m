#import <execinfo.h>
#import "JSStackTraceElement.h"

@implementation JSStackTraceElement

+ (NSString *)stackTraceString:(int)skipElements0 max:(int)maxElements {
  NSArray *array = [JSStackTraceElement stackTrace];

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
// line numbers are not meaningful
  //  return [NSString stringWithFormat:@"(%@ %d):%@",_className,_lineNumber,_methodName];
}

@end

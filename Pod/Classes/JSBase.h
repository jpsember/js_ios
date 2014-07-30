#import <Foundation/Foundation.h>

// This shouldn't be necessary, but the autocompletion is crippled without it, since DEBUG
// is unknown to it otherwise
#ifndef DEBUG
#define DEBUG 0
#endif

@protocol JSAppendStringProtocol;

typedef unsigned char byte;

@interface JSBase : NSObject

+ (void)dieWithMessage:(NSString *)message;
+ (void)dieWithFilename:(const char *)filename line:(int)line;
+ (NSString *)stringFromBool:(BOOL)b;
+ (NSString *)dumpBits:(uint)value;
+ (BOOL)testModeActive;
#if DEBUG
+ (NSString *)descriptionForPath:(NSString *)path lineNumber:(int)lineNumber;
+ (void)log:(NSString *)format, ...;
+ (void)flushLog;
+ (void)breakpoint;
+ (void)logString:(NSString *)string;
+ (void)pushLogHandler:(id<JSAppendStringProtocol>)handler;
+ (void)popLogHandler;
+ (void)oneTimeReport:(NSString *)fileAndLine message:(NSString *)message reportType:(NSString *)reportType;
+ (NSString *)symbolicNameForId:(id)object;
+ (NSString *)symbolicNameForPtr:(const void *) ptr;
+ (void)sleepFor:(float)timeInSeconds;
+ (void)showTimeStamp:(NSString *)format,...;

// Get array of StackTraceElement objects.
+ (NSMutableArray *)stackTrace;

+ (NSString *)stackTraceString:(int)skipElements max:(int)maxElements;

// Exposed for testing
+ (void)resetSymbolicPtrNames;
#endif

@end

#define ONCE_ONLY(__a__) { \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, __a__ ); \
}

#define dbits(__value__) [JSBase dumpBits:__value__]
#define dbool(__bool__) [JSBase stringFromBool:__bool__]

#if DEBUG

#define FLUSHLOG() [JSBase flushLog]

#define timeStamp(fmt,...) [JSBase showTimeStamp:fmt,##__VA_ARGS__]

// Convert pointer to symbolic string that is easier to read
#define dp(__id__) [JSBase symbolicNameForId:__id__]
#define dptr(__ptr__) [JSBase symbolicNameForPtr:__ptr__]

#define __FILE_AND_LINE__ [JSBase descriptionForPath:[NSString stringWithUTF8String:__FILE__] lineNumber:__LINE__]

// For overloading the global variable _DEBUG_PRINTING_
#pragma GCC diagnostic ignored "-Wshadow"

extern bool _DEBUG_PRINTING_;
#define DBG const bool _DEBUG_PRINTING_ = true; (void)_DEBUG_PRINTING_;
#define DBGIF(a) bool _DEBUG_PRINTING_ = (a); (void)_DEBUG_PRINTING_;
#define IFDBG(a) do {if (_DEBUG_PRINTING_) {a;}} while (0)
#define DBGWARN DBG warning(@"debug printing enabled");
#define pr(...) {if (_DEBUG_PRINTING_) [JSBase log:__VA_ARGS__];}

#define warning(__a__,...)  { NSString *__s__ = [NSString stringWithFormat:__a__,##__VA_ARGS__]; \
[JSBase oneTimeReport:__FILE_AND_LINE__ message:__s__ reportType:@"warning      "]; }

#define unimp(__a__,...)  { NSString *__s__ = [NSString stringWithFormat:__a__,##__VA_ARGS__]; \
[JSBase oneTimeReport:__FILE_AND_LINE__ message:__s__ reportType:@"unimplemented"]; }

#define die(__a__,...) { \
NSString *__s__ = @"(no reason given)"; \
if (__a__) __s__ = [NSString stringWithFormat:__a__,##__VA_ARGS__]; \
NSString *__m__ = [NSString stringWithFormat:@"*** fatal error %@: %@",__FILE_AND_LINE__,__s__]; \
[JSBase dieWithMessage:__m__]; \
}

#define MY_TEST_BEGIN [JSBase log:@"\n\n\n\n\n\n\n------ Testing: %@ ------\n\n",__FILE_AND_LINE__]; @try {
#define MY_TEST_END } \
@catch (NSException *e) { \
warning(@"Caught: %@\n",e); \
} @finally { \
if (_DEBUG_PRINTING_) { \
[JSBase log:@"\n\n\n...exiting"]; \
[JSBase sleepFor:2.0f]; \
exit(0); \
} \
}

#define ASSERT(__flag__,__a__,...) { \
    if (!(__flag__)) die(__a__,##__VA_ARGS__); \
}

@interface Inf : NSObject;
- (instancetype)initWithDescription:(NSString *)description maxIterations:(int)maxIter;
- (void)update;
@end
#define INF_DEFINE(...) \
  Inf *__infvar__ = [[Inf alloc] initWithDescription:(__FILE_AND_LINE__,##__VA_ARGS__) maxIterations:1000]
#define INF_DEFINEN(__x__,...) \
 Inf *__infvar__ = [[Inf alloc] initWithDescription:(__FILE_AND_LINE__,##__VA_ARGS__) maxIterations:__x__]

#define INF_UPDATE() [__infvar__ update]

#define NO_DEFAULT_INITIALIZER -(id)init { die(@"Please call the designated initializer"); return nil; }
#define USED_DEBUG_ONLY

#else // !DEBUG follows:

#define NO_DEFAULT_INITIALIZER
#define die(__a__,...) [JSBase dieWithFilename:__FILE__ line:__LINE__]
#define pr(...) {}
#define INF_DEFINE(...)
#define INF_DEFINEN(__x__,...)
#define INF_UPDATE()
#define ASSERT(__flag__,__a__,...)
#define IFDBG(a) 
#define warning(__a__,...)
#define unimp(__a__,...)
#define DBG
#define DBGIF(a)
#define IFDBG(a)
#define FLUSHLOG()
#define USED_DEBUG_ONLY __attribute__((unused))

#endif // DEBUG

#import "JSDieException.h"
#import "JSFreezable.h"
#import "JSStringUtil.h"
#import "JSPushPopProtocol.h"
#import "NSMutableString+JSMutableStringCategory.h"
#import "NSMutableArray+JSMutableArrayCategory.h"
#import "JSDictionaryUtil.h"
#import "JSFileUtil.h"
#import "JSOrderedSet.h"

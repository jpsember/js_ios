// This shouldn't be necessary, but the autocompletion is crippled without it, since DEBUG
// is unknown to it otherwise
#ifndef DEBUG
#define DEBUG 1
#endif

@protocol JSAppendStringProtocol;

typedef unsigned char byte;
#import "DebugTools.h"

@interface JSBase : NSObject

+ (void)dieWithMessage:(NSString *)message;
+ (void)dieWithFilename:(const char *)filename line:(int)line;
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

+ (void)exitApp;

// Exposed for testing
+ (void)resetSymbolicPtrNames;
#endif

@end

#define ONCE_ONLY(__a__) { \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, __a__ ); \
}

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

#define ASSERT(__flag__,__a__,...) { \
    if (!(__flag__)) die(__a__,##__VA_ARGS__); \
}

#define NO_DEFAULT_INITIALIZER -(id)init { die(@"Please call the designated initializer"); return nil; }
#define USED_DEBUG_ONLY

#else // !DEBUG follows:

#define NO_DEFAULT_INITIALIZER
#define die(__a__,...) [JSBase dieWithFilename:__FILE__ line:__LINE__]
#define pr(...) {}
#define ASSERT(__flag__,__a__,...)
#define warning(__a__,...)
#define unimp(__a__,...)
#define DBG
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

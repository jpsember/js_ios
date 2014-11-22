#import "JSBase.h"

@interface JSStackTrace : NSObject
+ (NSString *)stackTraceString:(int)skipElements max:(int)maxElements;
// Find nearest calling method in stack frame whose method name has a particular prefix.
// Returns string array [classname, methodname], or nil of no such caller found
+ (NSArray *)callerWithMethodNamePrefix:(NSString *)prefix;
@end



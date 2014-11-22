#import "JSBase.h"

@interface JSStackTraceElement : NSObject
@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *methodType;
@property (nonatomic, strong) NSString *methodName;
@property (nonatomic, assign) int lineNumber;


+ (NSString *)stackTraceString:(int)skipElements max:(int)maxElements;
+ (NSMutableArray *)stackTrace;
+ (JSStackTraceElement *)parse:(NSString *)string;

@end

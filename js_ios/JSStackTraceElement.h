#import "JSBase.h"

@interface JSStackTraceElement : NSObject
@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *methodType;
@property (nonatomic, strong) NSString *methodName;
@property (nonatomic, assign) int lineNumber;

+ (JSStackTraceElement *)parse:(NSString *)string;

@end

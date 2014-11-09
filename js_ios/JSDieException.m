
#import "JSDieException.h"

@implementation JSDieException

+ (NSString *)name {
  return @"JSDieException";
}

+ (JSDieException *)exceptionWithMessage:(NSString *)message {
  return [[self alloc] initWithMessage:message];
}

+ (JSDieException *)exceptionWithFormat:(NSString *)format,... {
  va_list vl;
  va_start(vl, format);
  NSString *message= [[NSString alloc] initWithFormat:format arguments:vl];
  va_end(vl);
  return [self exceptionWithMessage:message];
}

- (id)initWithMessage:(NSString *)message  {
  if (self = [super initWithName:[[self class] name] reason:message userInfo:nil]) {
  }
  return self;
}
      
@end

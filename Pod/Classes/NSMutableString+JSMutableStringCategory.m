#import "NSMutableString+JSMutableStringCategory.h"

@implementation NSMutableString ( JSMutableStringCategory )

- (void)clear {
  [self truncateToLength:0];
}

- (void)truncateToLength:(int)length {
  if ([self length] > length) {
    [self deleteCharactersInRange:NSMakeRange(length,[self length] - length)];
  }
}

@end


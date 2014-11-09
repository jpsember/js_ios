#import "JSBase.h"

@implementation NSMutableArray ( JSMutableArrayCategory )

- (id) pop {
  id result = [self lastObject];
  [self removeLastObject];
  return result;
}
- (void) push:(id)value {
  [self addObject:value];
}
- (void)reverse {
  NSUInteger count = self.count;
  NSUInteger midpoint = count / 2;
  for (NSUInteger i = 0; i < midpoint; i++) {
    [self exchangeObjectAtIndex:i withObjectAtIndex:count - 1 - i];
  }
}
- (id)peek {
  return [self peek:0];
}

- (id)peek:(NSUInteger)distanceFromTop {
  return [self objectAtIndex:self.count - 1 - distanceFromTop];
}


@end


#import "JSFreezable.h"

id frozenCopy(id<JSFreezable> original) {
  id copy = [original copyWithZone:NULL];
  [copy freeze];
  return copy;
}

id copyIfFrozen(id<JSFreezable> original) {
  if ([original frozen]) {
    return [original mutableCopyWithZone:NULL];
  }
  return original;
}


#include "JSBase.h"

#if DEBUG

#import "JSTestUtil.h"
#import "JSSymbolicNames.h"

@interface JSSymbolicNamesTests : JSTestCase
@end

@implementation JSSymbolicNamesTests

- (void)testSymbolicNamesUnique {
  JSSymbolicNames *n = [[JSSymbolicNames alloc] init];
  NSMutableSet *set = [NSMutableSet set];
  for (int i = 0; i < 8000; i++) {
    NSString *s = [n nameFor:(void *)i];
    XCTAssertFalse([set containsObject:s],@"!");
    XCTAssert([s length] <= 5,@"length of '%@' = %d!",s,[s length]);
    [set addObject:s];
  }
}

- (void)testSymbolicNameForNULL {
  JSSymbolicNames *n = [[JSSymbolicNames alloc] init];
  XCTAssertEqualObjects(@"null",[n nameFor:(void *)NULL]);
}

- (void)testSymbolicNamesConsistent {
  NSMutableArray *a = [NSMutableArray array];
  for (int pass = 0; pass < 2; pass++) {
    JSSymbolicNames *n = [[JSSymbolicNames alloc] init];
    for (int i = 0; i < 1000; i++) {
      NSString *s = [n nameFor:(void *)i];
      if (pass == 0) {
        [a addObject:s];
      } else {
        XCTAssertEqualObjects(a[i],s,@"expected equal");
      }
    }
  }
}

@end

#endif

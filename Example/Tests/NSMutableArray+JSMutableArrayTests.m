#import "JSTestUtil.h"

@interface JSMutableArrayTests : JSTestCase
@end

@implementation JSMutableArrayTests


- (NSMutableArray *)_array:(int)size {
  NSMutableArray *a = [NSMutableArray arrayWithCapacity:size];
  for (int i = 0; i < size; i++) {
    [a addObject:[NSString stringWithFormat:@"%02x",i]];
  }
  return a;
}

- (void)testReverse
{
  for (int size = 0; size < 20; size++) {
    NSMutableArray *a = [self _array:size];
    NSMutableArray *a2 = [self _array:size];
    
    [a reverse];
    for (int j = 0; j < size; j++) {
      id exp = a2[size-j-1];
      XCTAssertEqualObjects(a[j],exp,@"expected element %d of array of size %d to be %@, but was %@",
                            j,size,exp,a[j]);
    }}
}

@end
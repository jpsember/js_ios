#import "JSBase.h"
#import "JSTestUtil.h"

@interface FreezableTestObject : NSObject<JSFreezable>

@property (nonatomic, assign) int value;
@property (nonatomic, assign) BOOL frozen;

+ (FreezableTestObject *)build:(int)value;

@end

@implementation FreezableTestObject

+ (FreezableTestObject *)build:(int)value {
  FreezableTestObject *obj = [[self alloc] init];
  obj.value = value;
  return obj;
}

- (id)copyWithZone:(NSZone *)zone {
  if ([self frozen])
    return self;
  return [self mutableCopy];
}

// Get copy of self, one that is not frozen
- (id)mutableCopyWithZone:(NSZone *)zone {
  return [[self class] build:self.value];
}

- (void)freeze {
  self.frozen = YES;
}

#if DEBUG
- (void)setValue:(int)val {
  MUTABLE(self);
  _value = val;
}
#endif

@end

@interface JSFreezableTests : JSTestCase

@property (nonatomic, assign) int testObjectIndex;

@end

@implementation JSFreezableTests

- (FreezableTestObject *)tobj {
  self.testObjectIndex++;
  return [FreezableTestObject build:self.testObjectIndex];
}

- (void)testBuiltObjectInitiallyMutable {
  id item = [self tobj];
  XCTAssert(![item frozen]);
}

- (void)testMutableObjectIsMutable {
  FreezableTestObject *item = [self tobj];
  int val = item.value;
  item.value = val + 5;
  XCTAssert(item.value != val);
}

#if DEBUG
- (void)testFrozenObjectIsntMutable {
  FreezableTestObject *item = [self tobj];
  int val = item.value;
  [item freeze];
  XCTAssertExceptionWithSubstring(@"frozen", ^{item.value = val + 5; });
}
#endif

- (void)testFreezingReportsFrozen {
  id item = [self tobj];
  [item freeze];
  XCTAssert([item frozen]);
}

- (void)testCopyOfFrozenReturnsSameObject {
  id item = [self tobj];
  [item freeze];
  id item2 = [item copy];
  XCTAssert(item == item2);
}

- (void)testCopyOfMutableReturnsDifferentObject {
  id item = [self tobj];
  id item2 = [item copy];
  XCTAssert(item != item2);
}

- (void)testCopyIfFrozenReturnsOriginalIfNotFrozen {
  id item = [self tobj];
  id item2 = copyIfFrozen(item);
  XCTAssert(item2 == item);
}

- (void)testCopyIfFrozenReturnsMutableCopyIfFrozen {
  id item = [self tobj];
  [item freeze];
  FreezableTestObject *item2 = copyIfFrozen(item);
  XCTAssert(item2 != item);
  item2.value = 77;
  XCTAssert(item2.value == 77);
}

- (void)testFrozenCopyReturnsOriginalIfFrozen {
  id item = [self tobj];
  [item freeze];
  FreezableTestObject *item2 = frozenCopy(item);
  XCTAssert(item2 == item);
}

- (void)testFrozenCopyReturnsFrozenCopyIfMutable {
  FreezableTestObject *item = [self tobj];
  FreezableTestObject *item2 = frozenCopy(item);
  XCTAssert(item2 != item);
  item.value = 77;
#if DEBUG
  XCTAssertExceptionWithSubstring(@"frozen", ^{item2.value = 79; });
#endif
}

@end

#import "JSTestUtil.h"

//#define XCTAssertThrowsOur(expression, format...) \
//    XCTAssertThrowsSpecificNamed(expression, NSException, [JSSwizzler exceptionName], ## format);

@interface NSString ( JSSwizzleTestNSString )

+ (instancetype)__swizzled__stringWithCharacters:(const unichar *)chars length:(NSUInteger)length;
- (BOOL)__swizzled__boolValue;

@end

@implementation NSString ( JSSwizzleTestNSString )

+ (instancetype)__swizzled__stringWithCharacters:(const unichar *)chars length:(NSUInteger)length {
    return @"HELLO";
}
- (BOOL)__swizzled__boolValue {
    return NO;
}

@end


#define WITH_ALLOC_SWIZZLING 0

#if WITH_ALLOC_SWIZZLING

static int allocCount;

@interface NSObject ( JSSwizzleTestNSObject )
+ (id)__swizzled__alloc;
+ (id)__swizzled__allocWithZone:(NSZone *)zone;
@end

@implementation NSObject ( JSSwizzleTestNSObject )
+ (id)__swizzled__alloc {
  allocCount++;
  printf("swizzled alloc #%d, for class %s\n",allocCount,[[self description] UTF8String]);
  if (allocCount == 40) {
    printf("...returning nil\n");
    return nil;
  }
  return [self __swizzled__alloc];
}
+ (id)__swizzled__allocWithZone:(NSZone *)zone {
  printf("swizzled allocWithZone #%d, for class %s\n",allocCount,[[self description] UTF8String]);
  allocCount++;
  return [self __swizzled__allocWithZone:zone];
}

@end

#endif




@interface STestClass : NSObject
- (int)getValue;
+ (int)classMethod;
@end

@implementation STestClass
- (int)getValue {
    return 42;
}
+ (int)classMethod {
    return 88;
}
@end

@interface STestClass(STestClassCategory)
- (int)getValueTwo;
@end
@implementation STestClass(STestClassCategory)
- (int)getValueTwo {
    return 77;
}
@end

@interface JSSwizzlerTests : JSTestCase
@property (nonatomic, strong) JSSwizzler *swizzler;
@property (nonatomic, assign) int sampleValue;
@end


@implementation JSSwizzlerTests

- (void)exampleMethod
{
    self.sampleValue = 5;
}

- (int)exampleMethod2:(int)value
{
    self.sampleValue = value;
    return value * 2;
}

+ (int)exampleMethod3:(int)value
{
    return value + 2;
}

- (int)alternateMethod2:(int)value
{
    return value * 3;
}

- (void)setUp
{
    [super setUp];
    
    self.swizzler = [[JSSwizzler alloc] init];
}

- (void)tearDown
{
    [self.swizzler removeAll];
    [super tearDown];
}

- (BOOL)swiz1
{
    [self.swizzler add:[self class] methodName:@"exampleMethod" body:^(JSSwizzlerTests *_self){
        _self.sampleValue = 12;
    }];
    return YES;
}

- (BOOL)swiz2
{
    [self.swizzler add:[self class] methodName:@"exampleMethod2:" body:^(JSSwizzlerTests *_self, int value){
        _self.sampleValue = 15;
        return value * 3;
    }];
    return YES;
}

- (BOOL)swiz3
{
    [self.swizzler add:[self class] methodName:@"exampleMethod3:" body:^(id _class, int value){
        return value + 7;
    }];
    return YES;
}

- (void)unswiz1
{
    [self.swizzler remove:[self class] methodName:@"exampleMethod"];
}

- (void)unswiz2
{
    [self.swizzler remove:[self class] methodName:@"exampleMethod2:"];
}

- (void)unswiz3
{
    [self.swizzler remove:[self class] methodName:@"exampleMethod3:"];
}


- (void)testExternalClassInstanceMethod
{
    STestClass *s = [[STestClass alloc] init];
    
    XCTAssertEqual(42,[s getValue]);
    [self.swizzler add:[STestClass class] methodName:@"getValue" body:^(STestClass *_self){
        return 100;
    }];
    XCTAssertEqual(100,[s getValue]);
    [self.swizzler removeAll];
    XCTAssertEqual(42,[s getValue]);
}

- (void)testInstanceNoArguments
{
    [self exampleMethod];
    XCTAssertEqual(5,self.sampleValue);
    [self swiz1];
    [self exampleMethod];
    XCTAssertEqual(12,self.sampleValue,@"after swizzling");
    [self unswiz1];
    [self exampleMethod];
    XCTAssertEqual(5,self.sampleValue,@"after removing swizzle");
}

- (void)testInstanceWithArguments
{
    XCTAssertEqual(12,[self exampleMethod2:6]);
    [self swiz2];
    XCTAssertEqual(18,[self exampleMethod2:6]);
    [self unswiz2];
    XCTAssertEqual(12,[self exampleMethod2:6]);
}

- (void)testClassMethod
{
    XCTAssertEqual(10+2,[[self class] exampleMethod3:10]);
    [self swiz3];
    XCTAssertEqual(10+7,[[self class] exampleMethod3:10]);
    [self unswiz3];
    XCTAssertEqual(10+2,[[self class] exampleMethod3:10]);
}

- (void)testRemoveAll
{
    [self exampleMethod];
    XCTAssertEqual(5,self.sampleValue);
    XCTAssertEqual(12,[self exampleMethod2:6]);
    XCTAssertEqual(10+2,[[self class] exampleMethod3:10]);
    [self swiz1];
    [self swiz2];
    [self swiz3];
    [self.swizzler removeAll];
    [self exampleMethod];
    XCTAssertEqual(5,self.sampleValue,@"after removing swizzle");
    XCTAssertEqual(12,[self exampleMethod2:6]);
    XCTAssertEqual(10+2,[[self class] exampleMethod3:10]);
}

- (void)testSwizzleRepeatedly
{
    for (int i = 0; i < 20; i++) {
        int expected1;
        int expected2;
        int expected3;
        if ((i & 1) == 0) {
            [self swiz1];
            [self swiz2];
            [self swiz3];
            expected1 = 12;
            expected2 = 21;
            expected3 = 10+7;
        } else {
            [self unswiz1];
            [self unswiz2];
            [self unswiz3];
            expected1 = 5;
            expected2 = 14;
            expected3 = 10+2;
        }
        [self exampleMethod];
        XCTAssertEqual(expected1,self.sampleValue);
        XCTAssertEqual(expected2,[self exampleMethod2:7]);
        XCTAssertEqual(expected3,[[self class] exampleMethod3:10]);
    }
}

- (void) testAttemptSwizzleSameInstanceMethodTwice
{
  
    [self swiz1];
  
  XCTAssertExceptionWithSubstring(@"method already swizzled",^{[self swiz1];});
}

- (void) testAttemptSwizzleSameClassMethodTwice
{
  [self swiz3];
  XCTAssertExceptionWithSubstring(@"method already swizzled",^{[self swiz3];});
}

#if _SWIZZLE_SUPPORT_ORIGINAL_IMP_
- (void)testOriginalMethodWhenNotSwizzled
{
    XCTAssertThrowsOur([self.swizzler getOriginalImplementation:@"SwizzlerTests" methodName:@"exampleMethod" selectorPtr:nil implementationPtr:nil]);
}

- (void) testCallOriginalMethod
{
    [self exampleMethod];
    XCTAssertEqual(5,self.sampleValue);
    [self swiz1];
    [self exampleMethod];
    XCTAssertEqual(12,self.sampleValue,@"after swizzling");

    // This works but it's damned ugly.
    
    IMP imp;
    SEL sel;
    [self.swizzler getOriginalImplementation:@"SwizzlerTests" methodName:@"exampleMethod" selectorPtr:&sel implementationPtr:&imp];

    void (*func)(id, SEL) = (void *)imp;
    func(self, sel);
    XCTAssertEqual(5,self.sampleValue,@"after removing swizzle");

    [self exampleMethod];
    XCTAssertEqual(12,self.sampleValue,@"after swizzling");

    [self unswiz1];
    [self exampleMethod];
    XCTAssertEqual(5,self.sampleValue,@"after removing swizzle");
}
#endif

- (void)testSwap {
    XCTAssertEqual(12,[self exampleMethod2:6],@"before swizzling");
    
    [self.swizzler swap:[JSSwizzlerTests class] method1Name:@"exampleMethod2:" method2Name:@"alternateMethod2:"];
    XCTAssertEqual(18,[self exampleMethod2:6],@"after swizzling");
    
    int result = [self alternateMethod2:6];
    XCTAssertEqual(12,result,@"calling original method");
    
    [self.swizzler removeAll];
    XCTAssertEqual(12,[self exampleMethod2:6],@"after restoring");
}

- (void)testSwapWithStringCategory {
    
    static unichar w[] = {'a','b','c'};
    NSString *s2 = @"YES";
    
    XCTAssertEqualObjects([NSString stringWithCharacters:w length:3],@"abc");
    XCTAssertEqual([s2 boolValue],YES);
    
    [self.swizzler swap:[NSString class] method1Name:@"stringWithCharacters:length:" method2Name:@"__swizzled__stringWithCharacters:length:"];
    [self.swizzler swap:[NSString class] method1Name:@"boolValue" method2Name:@"__swizzled__boolValue"];
    
    XCTAssertEqualObjects([NSString stringWithCharacters:w length:3],@"HELLO");
    XCTAssertEqual([s2 boolValue],NO);
    
    [self.swizzler remove:[NSString class] methodName:@"stringWithCharacters:length:"];
    XCTAssertEqualObjects([NSString stringWithCharacters:w length:3],@"abc");
    XCTAssertEqual([s2 boolValue],NO);
    
    [self.swizzler removeAll];
    XCTAssertEqualObjects([NSString stringWithCharacters:w length:3],@"abc");
    XCTAssertEqual([s2 boolValue],YES);
}

- (void)testSwapWithOmittedSecondMethodName {
    
    static unichar w[] = {'a','b','c'};
    NSString *s2 = @"YES";
    
    XCTAssertEqualObjects([NSString stringWithCharacters:w length:3],@"abc");
    XCTAssertEqual([s2 boolValue],YES);
    
    [self.swizzler swap:[NSString class] methodName:@"stringWithCharacters:length:"];
    [self.swizzler swap:[NSString class] methodName:@"boolValue"];
    
    XCTAssertEqualObjects([NSString stringWithCharacters:w length:3],@"HELLO");
    XCTAssertEqual([s2 boolValue],NO);
    
    [self.swizzler remove:[NSString class] methodName:@"stringWithCharacters:length:"];
    XCTAssertEqualObjects([NSString stringWithCharacters:w length:3],@"abc");
    XCTAssertEqual([s2 boolValue],NO);
    
    [self.swizzler removeAll];
    XCTAssertEqualObjects([NSString stringWithCharacters:w length:3],@"abc");
    XCTAssertEqual([s2 boolValue],YES);
}

- (BOOL)_swap
{
    [self.swizzler swap:[NSString class] methodName:@"stringWithCharacters:length:"];
    return YES;
}

- (void)testAttemptSwapTwice
{
  [self _swap];
  XCTAssertExceptionWithSubstring(@"method already swizzled",^{[self _swap];});
}

- (void)testSwapUsingCategory
{
    STestClass *s = [[STestClass alloc] init];
    XCTAssert([s getValue] == 42);
    
    [self.swizzler swap:[STestClass class] method1Name:@"getValue" method2Name:@"getValueTwo"];
    XCTAssert([s getValue] == 77);
    [self.swizzler remove:[STestClass class] methodName:@"getValue"];
    XCTAssert([s getValue] == 42);
}

- (void)testSwizzleClassMethodWithBody {
    XCTAssert([STestClass classMethod] == 88);
    [self.swizzler add:[STestClass class] methodName:@"classMethod" body:^(id _self){return 100;}];
    XCTAssert([STestClass classMethod] == 100);
    [self.swizzler remove:[STestClass class] methodName:@"classMethod"];
    XCTAssert([STestClass classMethod] == 88);
}

#if WITH_ALLOC_SWIZZLING

- (void)testSwizzleAllocations {
  DBG
  
  allocCount = 0;

  [self.swizzler swap:[NSObject class] methodName:@"alloc"];
//  [self.swizzler swap:[NSObject class] methodName:@"allocWithZone:"];
  for (int i = 0; i < 100; i++) {
  NSMutableArray *a = [NSMutableArray arrayWithCapacity:20 ];
  pr(@"a=%@\n",dp(a));
  }
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  dict[@"a"] = @"alpha";
  dict[@"b"] = @"beta";
  for (int i = 0; i < 100; i++)
    dict[@(i)] = @"hey";
  JSRandom *r = [JSRandom randomWithSeed:452];
  
  pr(@" removing swizzles\n");
  [JSBase flushLog];
  [self.swizzler removeAll];
}
#endif


@end

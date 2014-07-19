#import "JSTestUtil.h"

@interface RandomTests : XCTestCase
@property (nonatomic, strong) JSSwizzler *swizzler;
@property (nonatomic, assign) int constValue;
@end

static int myConstValue;

@interface JSRandom (JSRandomTestsCategory88)
- (int)randomIntAlt88;
@end

@implementation JSRandom (JSRandomTestsCategory88)
- (int)randomIntAlt88 {
    return myConstValue;
}
@end


@implementation RandomTests

- (void) tearDown {
    [_swizzler removeAll];
}

- (JSSwizzler *) buildSwizzler {
    if (!_swizzler) {
        _swizzler = [[JSSwizzler alloc] init];
    }
    return self.swizzler;
}

#if DEBUG
- (void) testConsistentResultsWithSameSeed
{
    [JSIORecorder start];
    DBG
    pr(@"Within snapshot\n");
    int bits = 0;

    JSRandom *r = [JSRandom randomWithSeed:42];
    for (int i = 0; i < 100; i++) {
        int k = [r randomInt];
        bits |= k;
        pr(@" int=%d\n",k);
    }
    [JSIORecorder stop];
    XCTAssert(bits = 0x7fffffff);
}
#endif

- (void) testFloatRange
{
    JSRandom *r = [JSRandom randomWithSeed:42];
    for (int i = 0; i < 100; i++) {
        float f = [r randomFloat:5];
        XCTAssert(f >= 0 && f < 5.0);
    }
}

- (void) testIntRange
{
    JSRandom *r = [JSRandom randomWithSeed:55];
    for (int i = 0; i < 100; i++) {
        int f = [r randomInt:5];
        XCTAssert(f >= 0 && f < 5);
    }
}

#if DEBUG
- (void) testBool
{
    [JSIORecorder start];
    DBG
    pr(@"Within snapshot\n");
    JSRandom *r = [JSRandom randomWithSeed:43];
    for (int i = 0; i < 100; i++) {
        BOOL f = [r randomBoolean];
        pr(@" f=%d\n",f);
    }
    [JSIORecorder stop];
}
#endif

- (void) testDistinctTimerSeeds
{
    JSRandom *r1 = [JSRandom randomWithSeed:0];
    [NSThread sleepForTimeInterval: .05f];
    JSRandom *r2 = [JSRandom randomWithSeed:0];
    XCTAssert([r1 randomInt] != [r2 randomInt]);
}

- (void)testExtremalValues {
    [self buildSwizzler];
    RandomTests * __block ourSelf = self;
    [self.swizzler add:[JSRandom class] methodName:@"randomInt" body:^(id _self){
        return ourSelf.constValue;
    }];
    
    self.constValue = 0;
    JSRandom *r = [JSRandom randomWithSeed:42];
    
    XCTAssert([r randomFloat:5] == 0);
    self.constValue = RAND_MAX;
    float f = [r randomFloat:5];
    XCTAssert(f >= 4.999,@"got f=%f",f);
    f = [r randomFloat:RAND_MAX];
    XCTAssert(f >= RAND_MAX-1);
}

#if DEBUG
- (void)testPermutation {
    [JSIORecorder start];
    DBG
    pr(@"Test Permutation\n");
    JSRandom *r = [JSRandom randomWithSeed:43];
    for (int size = 0; size < 20; size++) {
        NSData *data = [r permutation:size];
        const int *p = [data bytes];
        pr(@"%2d elements: (",size);
        for (int i = 0; i < size; i++) {
            pr(@" %2d",p[i]);
        }
        pr(@" )\n");
    }
    [JSIORecorder stop];
}
#endif

@end

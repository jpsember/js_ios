#import "JSBase.h"
#import "JSTestUtil.h"
#import "JSStackTrace.h"
#import "js_iosTests-Swift.h"

@interface JSBaseTests : JSTestCase

@end

@implementation JSBaseTests

- (void)testBaseName
{
    XCTAssertEqualObjects(@"frank.mm",[@"/Volumes/Library/frank.mm" lastPathComponent]);
}

#if DEBUG
- (void)testAssert
{
    @try {
        ASSERT(false,@"alpha #%d",42);
        XCTFail(@"should not have got here");
    } @catch (JSDieException *e) {
        XCTAssert([[e reason] containsString: @"alpha"]);
        XCTAssert([[e reason] containsString: @"JSBaseTests.m"]);
        XCTAssert([[e reason] containsString: @"42"]);
    }
}

- (void)testAssertNilArguments
{
    @try {
        ASSERT(false,nil);
        XCTFail(@"should not have got here");
    } @catch (JSDieException *e) {
        XCTAssert([[e reason] containsString: @"no reason given"]);
        XCTAssert([[e reason] containsString: @"JSBaseTests.m"]);
    }
}
#endif

- (void)testDie
{
    @try {
        die(@"alpha");
        XCTFail(@"should not have got here");
    } @catch (JSDieException *e) {
#if DEBUG
        XCTAssert([[e reason] containsString: @"alpha"]);
#endif
        XCTAssert([[e reason] containsString: @"JSBaseTests.m"]);
    }
}

#if DEBUG
- (void)testSymbolicPtrNames
{
    [JSBase resetSymbolicPtrNames];
    
    [JSIORecorder start];
    DBG
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 300; i++) {
        id data = [NSMutableArray arrayWithCapacity:5];
        [array addObject:data];
        
        
        NSString *sym = dp(data);
        pr(@"%@ ",sym);
    }
    [JSIORecorder stop];
}

- (void)testStringHandler {

    DBG
    
    NSMutableString *buffer1 = [NSMutableString string];
    NSMutableString *buffer2 = [NSMutableString string];
    NSMutableString *buffer3 = [NSMutableString string];
    
    [JSBase pushLogHandler:(id<JSAppendStringProtocol>)buffer1];
    pr(@"Alpha");
    [JSBase pushLogHandler:(id<JSAppendStringProtocol>)buffer2];
    pr(@"Beta");
    [JSBase pushLogHandler:(id<JSAppendStringProtocol>)buffer3];
    pr(@"Gamma");
    [JSBase popLogHandler];
    pr(@"Beta");
    [JSBase popLogHandler];
    pr(@"Alpha");
    [JSBase popLogHandler];
    XCTAssertEqualObjects(@"AlphaAlpha",buffer1);
    XCTAssertEqualObjects(@"BetaBeta",buffer2);
    XCTAssertEqualObjects(@"Gamma",buffer3);
}

- (void)testDumpBits
{
    int v[] = {
        0,1,2,3,4,5,6,7,8,9,
        15,16,
        31,32,
        63,64,
        0x100,
        0x1000,
        0x10000,
        0x100000,
        0x1000000,
        0x10000000,
        0xfffffffe,
        0xffffffff,
    -99,
    };
    DBG
    [JSIORecorder start];
    for (int i = 0; v[i] != -99; i++) {
        pr(@"%10d = %@\n",v[i], dBits(v[i]) );
    }
    [JSIORecorder stop];
}

- (id)_alpha {
  return [self _beta];
}
- (id)_beta {
  return [self _gamma];
}
- (id)_gamma {
  return [JSStackTrace stackTraceString:0 max:3];
}

- (void)testStackTraceString {
  
  [JSIORecorder start];
  DBG
  
  id s = [self _alpha];

  pr(@"stack trace:\n%@\n",s);
  
  [JSIORecorder stop];
  
}
#endif

@end

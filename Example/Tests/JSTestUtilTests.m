#import <QuartzCore/QuartzCore.h>

#import "JSTestUtil.h"

@interface JSTestUtilTests : JSTestCase
@property (nonatomic,assign) NSTimeInterval startTime;
@end


@implementation JSTestUtilTests

- (void)setUp
{
    [super setUp];
    self.startTime = CACurrentMediaTime();
}

- (void)testRunBlockUntilTrue
{
    NSTimeInterval endTime = self.startTime + .75f;
    BOOL result = [[self class] runBlockUntilTrue:1.0f block:^{
        return (BOOL)(CACurrentMediaTime() >= endTime);
    }];
    XCTAssert(result && CACurrentMediaTime() >= endTime);
}

- (void)testRunBlockUntilTrueFails
{
    XCTAssertFalse([[self class] runBlockUntilTrue:1.0f block:^{
        return NO;
    }]);
}


- (void)testAssertionWithSubstring {
  NSString *problem = [JSTestCase verifyExceptionWithSubstring:@"alpha" block:^{
    @throw [[NSException alloc] initWithName:@"testing" reason:@"This string contains Alpha (case insensitive)" userInfo:nil];
  }];
  XCTAssert(!problem);
}

- (void)testAssertionWithSubstringFailure1 {
  NSString *problem = [JSTestCase verifyExceptionWithSubstring:@"alpha" block:^{
    [NSThread sleepForTimeInterval: .02];
  }];
  XCTAssert([problem containsString:@"Did not catch any"]);
}

- (void)testAssertionWithSubstringFailure2 {
  NSString *problem = [JSTestCase verifyExceptionWithSubstring:@"alpha" block:^{
    @throw [[NSException alloc] initWithName:@"testing" reason:@"beta" userInfo:nil];
  }];
  XCTAssert([problem containsString:@"does not contain substring"]);
}

- (void)testAssertionWithSubstringMacro {
  XCTAssertExceptionWithSubstring(@"alpha", ^{
    [JSBase dieWithMessage:@"Problem involving Alpha"];});
}



@end

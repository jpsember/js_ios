#import "JSTestUtil.h"

@interface JSDictionaryUtilTests : XCTestCase
@end

@implementation JSDictionaryUtilTests

- (void)testContainsKey{
    NSDictionary *dict = @{@"abc":@1, @"def":@2};
    
    XCTAssert([dict containsKey: @"abc"]);

    XCTAssert(![dict containsKey: @"cde"]);
}

@end
// This should only be included by files in an app's test directory

#import <XCTest/XCTest.h>
#import "JSBase.h"
#import "JSSwizzler.h"
#import "JSIORecorder.h"
#import "JSRandom.h"

#define XCTAssertExceptionWithSubstring(__substring__,__block__) { \
  NSString *__result__ = [JSTestCase verifyExceptionWithSubstring:__substring__ block:__block__]; \
  XCTAssert(!__result__,@"%@",__result__); \
}

@interface JSTestCase : XCTestCase

@property (nonatomic, strong) JSRandom *random;

+ (NSString *)randomTemporaryDirectory;
+ (BOOL)runBlockUntilTrue:(NSTimeInterval)timeInterval block:(BOOL(^)(void))block;

// Verify that calling a block throws an NSException with a particular substring in its description.
// Returns nil if success, else a string describing the problem.
// This is designed to be called by the 'XCTAssertExceptionWithSubstring' macro (so errors report the
// caller's class, not the JSTestCase base class).
+ (NSString *)verifyExceptionWithSubstring:(NSString *)str block:(void (^)(void))b;

- (int)randomInt:(int)range;


@end


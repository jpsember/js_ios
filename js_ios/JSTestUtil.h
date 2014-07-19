// This should only be included by files in an app's test directory

#import <XCTest/XCTest.h>
#import "JSBase.h"
#import "JSSwizzler.h"
#import "JSIORecorder.h"
#import "JSRandom.h"

#define ENDM -999999

#define Match_f(a1,a2, format...) \
XCTAssertEqualWithAccuracy(a1, a2, 1e-4, ## format)

#define Match_pt(p1,p2, format...) { \
Match_f(p1.x,p2.x,## format); \
Match_f(p1.y,p2.y,## format); }

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


#if DEBUG

#import "JSTestUtil.h"

@interface IORecorderTests : XCTestCase
@end

@implementation IORecorderTests

- (void) testRecording
{
    [JSIORecorder start];
    DBG
    pr(@"Within snapshot\n");
    [JSIORecorder stop];
}

@end

#endif

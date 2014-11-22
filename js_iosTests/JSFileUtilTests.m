#import "JSTestUtil.h"

@interface FileUtilTests : JSTestCase
@property (nonatomic, copy) NSString *tempDirectory;
@end

@implementation FileUtilTests

- (NSString *)_tempDir {
    if (!self.tempDirectory) {
        self.tempDirectory = [[self class] randomTemporaryDirectory];
    }
    return self.tempDirectory;
}

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    if (self.tempDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:self.tempDirectory error:nil];
    }
    [super tearDown];
}

@end
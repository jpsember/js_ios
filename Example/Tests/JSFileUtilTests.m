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

- (void)testRemoveItemsFromDirectoryDoesNotCreateNonexistentDirectory
{
  NSFileManager *m = [NSFileManager defaultManager];
  NSString *dir = [self _tempDir];
  NSString *subdir = [dir stringByAppendingPathComponent:@"mysubdir"];
  XCTAssert(![m fileExistsAtPath:subdir isDirectory:nil]);
  NSError *err = nil;
  [m removeAllItemsFromDirectory:subdir error:&err];
  XCTAssert(!err,@"got error %@",err);
  XCTAssert(![m fileExistsAtPath:subdir isDirectory:nil]);
}

- (void)testRemoveItemsFromDirectory
{
  NSFileManager *m = [NSFileManager defaultManager];
  NSString *dir = [self _tempDir];
  NSString *subdir = [dir stringByAppendingPathComponent:@"mysubdir"];
  NSString *filePath1 = [subdir  stringByAppendingPathComponent:@"alpha.txt"];
  
  NSString *subdir2 = [subdir stringByAppendingPathComponent:@"mysubdir2"];
  NSString *filePath2 = [subdir2 stringByAppendingPathComponent:@"beta.txt"];
  NSString *subdir3 = [subdir2 stringByAppendingPathComponent:@"mysubdir3"];
  NSString *filePath3 = [subdir3 stringByAppendingPathComponent:@"gamma.txt"];
  XCTAssert([m createDirectoryAtPath:subdir3 withIntermediateDirectories:YES attributes:nil error:nil]);
  NSError *error = nil;
  [@"arbitrarydata" writeToPath:filePath1 error:&error];
  [@"arbitrarydata" writeToPath:filePath2 error:&error];
  [@"arbitrarydata" writeToPath:filePath3 error:&error];
  XCTAssertNil(error);
  
  [m removeAllItemsFromDirectory:subdir2 error:&error];
  XCTAssert(!error);
  XCTAssert([m fileExistsAtPath:subdir2 isDirectory:nil]);
  XCTAssert([m fileExistsAtPath:filePath1 isDirectory:nil]);
  XCTAssert(![m fileExistsAtPath:subdir3 isDirectory:nil]);
  XCTAssert(![m fileExistsAtPath:subdir3 isDirectory:nil]);
  XCTAssert(![m fileExistsAtPath:filePath2 isDirectory:nil]);
}

@end
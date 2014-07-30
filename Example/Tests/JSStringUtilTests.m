#import "JSTestUtil.h"

@interface StringUtilTests : JSTestCase
@property (nonatomic, copy) NSString *tempDirectory;
@end

@implementation StringUtilTests

- (NSString *)_tempDir {
    if (!self.tempDirectory) {
        self.tempDirectory = [JSTestCase randomTemporaryDirectory];
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

- (void)testContainsString
{
    XCTAssert([@"abcdef" containsString:@"def"]);
    XCTAssert([@"abcdef" containsString:@"abcdef"]);
    XCTAssert([@"abcdef" containsString:@"ab"]);

    XCTAssert(![@"abcdef" containsString:@""]);
    XCTAssert(![@"abcdef" containsString:@"df"]);
    XCTAssert(![@"abcdef" containsString:@"abcdeff"]);
    XCTAssert(![@"" containsString:@"abcdef"]);
}

- (void)testIndexOf
{
  XCTAssertEqual([@"abcdef" indexOf:@"cde"],2);
  XCTAssertEqual([@"abcdefabcdef" indexOf:@"cde"],2);
  XCTAssertEqual([@"abcdef" indexOf:@"z"],-1);
#if DEBUG
  XCTAssertExceptionWithSubstring(@"not found within",^{[@"abcdef" indexOf:@"z" mustExist:YES];});
#endif
}

- (NSString *)auxPath {
    return [NSString stringWithFormat:@"%@/work.txt",[self _tempDir]];
}

- (void)testWriteToPath {
  NSError *error = nil;
  
    NSString *content = @"alpha.txt";
    NSString *path = [self auxPath];
    [content writeToPath:path error:&error];
    XCTAssertNil(error);
  
    NSFileManager *m = [NSFileManager defaultManager];
    XCTAssert([m fileExistsAtPath:path]);
    
    NSString *readBack = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
  XCTAssertNil(error);
    XCTAssertEqualObjects(content,readBack);
}

- (void)testReadFromPath {
  NSError *error = nil;
  NSString *content = @"abracadabra";
    NSString *path = [self auxPath];
    [content writeToFile:path  atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSString *readBack = [NSString readFromPath:path error:&error];
  XCTAssertNil(error);
  XCTAssertEqualObjects(content,readBack);
}

- (void)testReadFromPathNonExistent {
  NSError *error = nil;
  NSString *content = @"abracadabra";
    NSString *path = [self auxPath];
    
    NSString *readBack = [NSString readFromPath:path defaultContents:@"abracadabra" error:&error];
    XCTAssertEqualObjects(content,readBack);
    NSFileManager *m = [NSFileManager defaultManager];
    XCTAssert(![m fileExistsAtPath:path]);
}

- (void)testWriteToPathEvenIfUnchanged {
  NSError *error = nil;
  NSString *content = @"abracadabra";
    NSString *path = [self auxPath];
    XCTAssert([content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error]);
    NSFileManager *m = [NSFileManager defaultManager];
    
    NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:200];
    NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:300];
    id dictionary = @{ NSFileCreationDate : date1 , NSFileModificationDate : date2 };
    XCTAssert( [m setAttributes:dictionary ofItemAtPath:path error:&error]);
    
  [content writeToPath:path error:&error];
    NSDictionary *dict2 = [m attributesOfItemAtPath:path error:&error];
    XCTAssert(dict2);
    NSDate *date3 = dict2[NSFileModificationDate];
    XCTAssert([date3 compare:date2] > 0);
  XCTAssertNil(error);
}

- (void)testWriteToPathIfUnchanged {
  NSError *error = nil;
  NSString *content = @"abracadabra";
    NSString *path = [self auxPath];
    XCTAssert([content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error]);
    
    NSFileManager *m = [NSFileManager defaultManager];
    
    NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:200];
    NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:300];
    id dictionary = @{ NSFileCreationDate : date1 , NSFileModificationDate : date2 };
    XCTAssert( [m setAttributes:dictionary ofItemAtPath:path error:nil]);
    
  [content writeToPath:path onlyIfChanged:YES error:&error];
    NSDictionary *dict2 = [m attributesOfItemAtPath:path error:&error];
    XCTAssert(dict2);
    NSDate *date3 = dict2[NSFileModificationDate];
    XCTAssert([date3 compare:date2] == 0);
  XCTAssertNil(error);
}

- (void)testTrimWhitespace {
  NSArray *a = @[
                 @"Hello",@"Hello",
                 @"    Hello  ",@"Hello",
                 @"  \nHello\n\n Hey  ",@"Hello\n\n Hey",
                 @"   ",@"",
                 ];
  
  for (int i = 0; i < a.count; i+=2) {
    NSString *s1 = a[i];
    NSString *s2Exp = a[i+1];
    NSString *s2Got = [s1 trimWhitespace];
    XCTAssertEqualObjects(s2Exp,s2Got);
  }
}

- (void)testReplacingExtension {
  NSArray *a = @[@"a/foo.txt",@"ps",@"a/foo.ps",
                  @"a/foo",@"ps",@"a/foo.ps",
                  @"a/.foo",@"ps",@"a/.foo.ps",
                 ];
  
  for (int i = 0; i < a.count; i+=3) {
    NSString *path = a[i];
    NSString *ext = a[i+1];
    NSString *exp = a[i+2];
    NSString *got = [path stringByReplacingPathExtensionWith:ext];
    XCTAssertEqualObjects(exp,got);
  }
}

@end
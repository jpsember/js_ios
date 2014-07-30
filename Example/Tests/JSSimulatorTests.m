#import "JSTestUtil.h"
#import "JSSimulator.h"

#define XCTAssertThrowsOur(expression, format...) \
XCTAssertThrowsSpecificNamed(expression, NSException, [Swizzler exceptionName], ## format);

@interface SimulatorTests : XCTestCase
@property (nonatomic, strong) JSSwizzler *swizzler;
@property (nonatomic, strong) NSString *theNewFilesPath;
@end

@implementation SimulatorTests

- (void)setUp
{
    [super setUp];
    
    self.swizzler = [[JSSwizzler alloc] init];
}

- (void)tearDown
{
    if (self.theNewFilesPath) {
        [[NSFileManager defaultManager] removeItemAtPath:self.theNewFilesPath error:nil];
    }
    
    [self.swizzler removeAll];
    [super tearDown];
}

- (JSSimulator *)buildSim {
    [self.swizzler add:[JSSimulator class] methodName:@"getNewFilesDirectoryName" body:^(id _self){return @"__test__newfiles";}];
    JSSimulator *simulator = [[JSSimulator alloc] init];
    self.theNewFilesPath = simulator.filesDumpPath;
    return simulator;
}

- (void)testSwizzledNewFilesName
{
    JSSimulator *s = [self buildSim];
    NSString *path = s.filesDumpPath;
    XCTAssert([path hasSuffix:@"__test__newfiles"],@"path was '%@', unexpected suffix",path);
}

- (void)testPathForReading
{
    JSSimulator *s = [self buildSim];
  NSError *error = nil;
  NSString *path = [s resourcePath:@"subdirectory/foo.txt" forWriting:NO error:&error];
    
    XCTAssertEqualObjects(path,[s.appResourcesPath stringByAppendingPathComponent:@"subdirectory/foo.txt"],
                          @"got path '%@'",path);
}

- (void)testReadResource {
  JSSimulator *s = [self buildSim];
  NSError *error = nil;
  NSString *content = [s readStringFrom:@"subdirectory/foo.txt" error:&error];
  XCTAssert([content hasPrefix:@"contents of foo.txt"],@"content '%@' was unexpected",content);
}

- (void)testPathForWriting
{
    JSSimulator *s = [self buildSim];
  NSError *error = nil;
  NSString *path = [s resourcePath:@"subdirectory/foo.txt" forWriting:YES error:&error];
    XCTAssertEqualObjects(path,[s.filesDumpPath stringByAppendingPathComponent:@"subdirectory/foo.txt"],
                          @"got path '%@'",path);
}

- (NSDictionary *)_getNewFiles:(JSSimulator *)simulator {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:simulator.filesDumpPath];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSString *file;
    while ((file = [dirEnum nextObject])) {
        NSString *dumpedPath = [simulator.filesDumpPath stringByAppendingPathComponent:file];
        BOOL isDir;
        [fileManager fileExistsAtPath:dumpedPath isDirectory:&isDir];
        if (!isDir) {
          NSError *error = nil;
          dict[file] = [NSString readFromPath:dumpedPath error:&error];
          XCTAssertNil(error);
        }
    }
    return dict;
}

- (void)testWriteStringResource {
    NSArray *files = @[@"alpha.txt",@"alpha",@"jupiter/beta.txt",@"beta",@"saturn/apollo/gamma.txt",@"gamma"];
    
    JSSimulator *s = [self buildSim];
    for (int i = 0; i < [files count]; i += 2) {
      NSError *error = nil;
      [s writeString:[files objectAtIndex:i+1] toResourcePath:[files objectAtIndex:i] error:&error];
      XCTAssertNil(error);
    }
    NSDictionary *dict = [self _getNewFiles:s];
    for (int i = 0; i < [files count]; i += 2) {
        NSString *resName = [files objectAtIndex:i];
        NSString *content = [files objectAtIndex:i+1];
        XCTAssert([dict containsKey:resName],@"dictionary doesn't contain '%@'",resName);
        XCTAssertEqualObjects(content,dict[resName]);
    }
}

- (void)testWriteResource {
    JSSimulator *s = [self buildSim];
    NSString *resName = @"alpha.txt";
  
  NSError *error = nil;
  NSString *path = [s resourcePath:resName forWriting:YES error:&error];
    NSString *content = @"abracadabra";
  [content writeToPath:path error:&error];
  XCTAssertNil(error);
  
  NSString *content2 = [NSString readFromPath:path error:&error];
    XCTAssertEqualObjects(content,content2);
    
    NSDictionary *dict = [self _getNewFiles:s];
    XCTAssert([dict containsKey:resName],@"dictionary doesn't contain '%@'",resName);
    XCTAssertEqualObjects(content,dict[resName]);
}

@end

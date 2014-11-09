#import "JSTestUtil.h"


@implementation JSTestCase

+ (NSString *)randomTemporaryDirectory {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *tempDir = nil;
  NSString *baseDir = NSTemporaryDirectory();
  double timeValue = CACurrentMediaTime();
  while (true) {
    double intpart;
    double fraction = modf(timeValue, &intpart);
    NSMutableString *str = [NSMutableString string];
    NSString *seed = [NSString stringWithFormat:@"%d",(int)(fraction * 1000000)];
    const int LENGTH = 20;
    while ([str length] < LENGTH) {
      [str appendString:seed];
    }
    NSString *subdirName = [str substringToIndex:LENGTH];
    tempDir = [baseDir stringByAppendingPathComponent:subdirName];
    if (![fileManager fileExistsAtPath:tempDir isDirectory:nil])
      break;
    timeValue += .1234567;
  }
  BOOL success = [fileManager createDirectoryAtPath:tempDir withIntermediateDirectories:YES attributes:nil error:nil];
  ASSERT(success,@"unable to create temporary directory %@",tempDir);
  success = NO; // gets rid of warning in nondebug
  return tempDir;
}

+ (BOOL)runBlockUntilTrue:(NSTimeInterval)timeInterval block:(BOOL (^)(void))block {
  NSTimeInterval stopTime = CACurrentMediaTime() + timeInterval;
  
  __block BOOL result = NO;
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(queue,^{
    while (true) {
      result = block();
      if (result)
        break;
      if (CACurrentMediaTime() >= stopTime)
        break;
    }
  });
  
  while (!result) {
    if (CACurrentMediaTime() >= stopTime)
      break;
    [NSThread sleepForTimeInterval:.05];
  }
  return result;
}

- (void)setUp {
  [super setUp];
  _random = [JSRandom randomWithSeed:1965];
}

- (int)randomInt:(int)range {
    return [_random randomInt:range];
}

- (void)assertExceptionWithSubstring:(NSString *)str block:(void (^)(void))userBlock {
  NSException *exceptionReceived = nil;
  @try {
    userBlock();
  } @catch (NSException *err) {
    exceptionReceived = err;
  }
  XCTAssert(exceptionReceived,@"Did not catch any exceptions; expected one with substring '%@'",str);
  NSString *desc = [exceptionReceived description];
  XCTAssert([[desc lowercaseString] containsString:[str lowercaseString]],
            @"Exception '%@' does not contain substring '%@'",desc,str);
}

+ (NSString *)verifyExceptionWithSubstring:(NSString *)str block:(void (^)(void))userBlock {
  NSException *exceptionReceived = nil;
  @try {
    userBlock();
  } @catch (NSException *err) {
    exceptionReceived = err;
  }
  if (!exceptionReceived)
    return [NSString stringWithFormat:@"Did not catch any exceptions; expected one with substring '%@'",str];
  if ([str hasPrefix:@"!"]) {
    if (!DEBUG)
      return nil;
    str = [str substringFromIndex:1];
  }
  NSString *desc = [exceptionReceived description];
  if (![[desc lowercaseString] containsString:[str lowercaseString]]) {
    return [NSString stringWithFormat:@"Exception '%@' does not contain substring '%@'",desc,str];
  }
  return nil;
}

@end

#import "JSBase.h"
#import "JSLog.h"
#import "JSIORecorder.h"
#import "JSStackTrace.h"
#import "JSSimulator.h"

#if !DEBUG
@implementation JSIORecorder

+ (JSIORecorder *)start:(BOOL)replaceIfChanged {
  return nil;
}

+ (JSIORecorder *)start:(BOOL)replaceIfChanged className:(NSString *)className methodName:(NSString *)methodName {
  return nil;
}

+ (JSIORecorder *)start {
  return nil;
}

+ (JSIORecorder *)startWithClassName:(NSString *)c methodName:(NSString *)m replaceIfChanged:(BOOL)r {
  return nil;
}

+ (void)stop {
}

+ (NSString *)exceptionName {
  return nil;
}

@end

#else

@interface JSIORecorder ()

@property(nonatomic, copy) NSString *filename;
@property(nonatomic, strong) NSMutableString *stringBuffer;
@property(nonatomic, assign) BOOL replaceIfChanged;

@end

static JSIORecorder *activeRecorder;

@implementation JSIORecorder

+ (JSIORecorder *)start:(BOOL)replaceIfChanged {
  NSArray *names = [JSStackTrace callerWithMethodNamePrefix:@"test"];
  if (!names) {
    die(@"Can't find caller with prefix 'test'");
  }
  NSString *className = names[0];
  NSString *methodName = names[1];
  return [JSIORecorder start:replaceIfChanged className:className methodName:methodName];
}

+ (JSIORecorder *)start:(BOOL)replaceIfChanged className:(NSString *)className methodName:(NSString *)methodName {
  if (replaceIfChanged) warning(@"JSIORecorder replacing old for %@:%@", className, methodName);
  return [self startWithClassName:className methodName:methodName replaceIfChanged:replaceIfChanged];
}

+ (JSIORecorder *)start {
  return [JSIORecorder start:NO];
}

+ (JSIORecorder *)startWithClassName:(NSString *)c methodName:(NSString *)m replaceIfChanged:(BOOL)r {
  return [[JSIORecorder alloc] initWithClassName:c methodName:m replaceIfChanged:r];
}

+ (void)stop {
  [activeRecorder _close];
}

- (instancetype)initWithClassName:(NSString *)className methodName:(NSString *)methodName replaceIfChanged:(BOOL)r {
  if (self = [super init]) {
    _filename = [NSString stringWithFormat:@"_snapshots_/%@/%@.txt", className, methodName];
    _replaceIfChanged = r;

    ASSERT(!activeRecorder, @"A recorder is already active: %@", activeRecorder);

    // If some other recorder is active, close it
    [activeRecorder _close];

    _stringBuffer = [NSMutableString string];

    [JSLog pushLogHandler:(id <JSAppendStringProtocol>) self.stringBuffer];

    activeRecorder = self;
  }
  return self;
}

- (NSString *)_getPathForContent:(NSString *)content {
  NSString *path = self.filename;
  if ([content hasPrefix:@"%!PS\n"]) {
    path = [path stringByReplacingPathExtensionWith:@"ps"];
  }
  return path;
}

- (void)_close {
  const int kMaxDisplaySize = 20000;

  if (activeRecorder == self) {
    JSIORecorder *saveUntilDoneHere = activeRecorder;
    activeRecorder = nil;
    [JSLog popLogHandler];
    NSString *content = self.stringBuffer;
    NSString *snapshotPath;

    NSError *error = nil;

    BOOL fileAlreadyExists = NO;
    NSString *errorMessage = nil;

    if (!_replaceIfChanged) {
      // If snapshot already exists, compare with it; otherwise, create it
      snapshotPath = [[JSSimulator sharedInstance] resourcePath:[self _getPathForContent:content] forWriting:NO error:&error];
      ASSERT(!error, 0);

      NSFileManager *fileManager = [NSFileManager defaultManager];
      fileAlreadyExists = [fileManager fileExistsAtPath:snapshotPath];
      if (fileAlreadyExists) {
        NSString *oldContent = [NSString readFromPath:snapshotPath error:&error];
        ASSERT(!error, 0);
        if (![oldContent isEqualToString:content]) {
          if (MAX([oldContent length], [content length]) > kMaxDisplaySize) {
            errorMessage = [NSString stringWithFormat:@"Unexpected snapshot content (large size, not printing); path '%@'", snapshotPath];
          } else {
            errorMessage = [NSString stringWithFormat:@"Expected snapshot content:\n"
                                                          "---\n"
                                                          "%@\n"
                                                          "---\n"
                                                          "But got:\n"
                                                          "---\n"
                                                          "%@", oldContent, content];
          }
        }
      }
    }

    // Possibilities:
    // 1) no file exists        : write it
    // 2) file exists, no error : don't write it
    // 3) file exists, error    : write new to temporary location
    //

    if (!fileAlreadyExists || errorMessage) {
      NSString *resourcePath = [self _getPathForContent:content];
      if (errorMessage) {
        // Insert extra suffix to distinguish this from the 'true' or desired path
        NSString *ext = [resourcePath pathExtension];
        resourcePath = [NSString stringWithFormat:@"%@_TEMP_.%@", [resourcePath stringByDeletingPathExtension], ext];
      }

      snapshotPath = [[JSSimulator sharedInstance] resourcePath:resourcePath forWriting:YES error:&error];
      ASSERT(!error, 0);
      if (!errorMessage) {
        puts("\n----------------------------------------------------------------------------");
        printf("Writing new snapshot to %s:\n", [snapshotPath UTF8String]);
        if ([content length] <= kMaxDisplaySize) {
          puts("----------------------------------------------------------------------------");
          puts([content UTF8String]);
        }
        puts("----------------------------------------------------------------------------\n\n");
      }
      [content writeToPath:snapshotPath error:&error];
      ASSERT(!error, 0);
    }

    if (errorMessage) {
      [[self class] _toss:errorMessage];
    }

    // We may have trouble releasing this here, if the optimizer decides to release it early...
    saveUntilDoneHere = nil;
  }
}

+ (NSString *)exceptionName {
  return @"IORecorderException";
}

+ _toss:(NSString *)message {
  @throw [JSDieException exceptionWithMessage:message];
}

@end

#endif

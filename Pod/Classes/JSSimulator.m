#if TARGET_IPHONE_SIMULATOR

#import "JSBase.h"

#import "JSSimulator.h"

@interface JSSimulator()
@property (nonatomic, copy) NSString *appResourcesWritePath;
@property (nonatomic, assign) int nextSignalValue;
@end

@implementation JSSimulator

+ (JSSimulator *)sharedInstance {
    static JSSimulator *simulator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        simulator = [[JSSimulator alloc] init];
    });
    return simulator;
}

- (instancetype)init {
    if (self = [super init]) {
        [self _findAppResources];
        if (![self _prepareResourceWriting:NULL])
          return nil;
    }
    return self;
}

- (NSString *)resourcePath:(NSString *)relativeResourcePath forWriting:(BOOL)forWriting error:(NSError **)error {
  //    DBG
  pr(@"resourcePath '%@' forWriting %d\n",relativeResourcePath,forWriting);
  NSFileManager *fileManager = [NSFileManager defaultManager];
  // See if this file exists in the new files directory
  NSString *pathWithinNewFiles = [self.filesDumpPath stringByAppendingPathComponent:relativeResourcePath];
  pr(@" pathWithinNewFiles='%@'\n",pathWithinNewFiles);
  if (forWriting || [fileManager fileExistsAtPath:pathWithinNewFiles isDirectory:nil]) {
    if (![fileManager createDirectoryAtPath:[pathWithinNewFiles stringByDeletingLastPathComponent]
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:error])
      return nil;
    return pathWithinNewFiles;
  }
  NSString *pathWithinResources = [self.appResourcesPath stringByAppendingPathComponent:relativeResourcePath];
  pr(@" returning pathWithinResources '%@'\n",pathWithinResources);
  return pathWithinResources;
}

- (NSString *)readStringFrom:(NSString *)relativeResourcePath error:(NSError **)error  {
  NSString *path = [self resourcePath:relativeResourcePath forWriting:NO error:error];
  if (!path)
    return nil;
  
  return [NSString readFromPath:path error:error];
}

- (BOOL)writeString:(NSString *)string toResourcePath:(NSString *)relativeResourcePath error:(NSError **)error {
    NSString *writePath = [self resourcePath:relativeResourcePath forWriting:YES error:error];
    if (!writePath)
      return NO;
  return [string writeToPath:writePath error:error];
}

+ (NSString *)getNewFilesDirectoryName {
    return @"_newfiles_";
}

- (void)_findAppResources {
//#if DEBUG
  if ([JSBase testModeActive]) {
    NSString *app_resources_name = @"test_resources";
    NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"JSTestAppDelegate") ];
    NSURL *appResourcesURL = [bundle URLForResource:app_resources_name withExtension:nil];
    if (!appResourcesURL) die(@"could not locate app_resources; app_resources_name=%@ bundle %@",app_resources_name,bundle);
    self.appResourcesPath = appResourcesURL.path;
  }
  else
//#endif
  {
    NSString *app_resources_name = @"app_resources";
    NSBundle *bundle = [NSBundle mainBundle] ;
    NSURL *appResourcesURL = [bundle URLForResource:app_resources_name withExtension:nil];
    if (!appResourcesURL) die(@"could not locate app_resources; app_resources_name=%@ bundle %@",app_resources_name,bundle);
    self.appResourcesPath = appResourcesURL.path;
  }
}

+ (NSString *)_applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    if (!basePath) die(@"could not locate Documents directory");
    return basePath;
}

- (BOOL)_prepareResourceWriting:(NSError **)error {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *docPath = [[self class] _applicationDocumentsDirectory];
  NSString *pathToNewFiles = [docPath stringByAppendingPathComponent:[[self class] getNewFilesDirectoryName]];
  
  if (![fileManager createDirectoryAtPath:pathToNewFiles withIntermediateDirectories:YES attributes:nil error:error])
    return NO;
  // Don't remove files from this directory; we'll remove these files as we copy them within simbuddy.
  
  self.filesDumpPath = pathToNewFiles;
  return YES;
}

#if DEBUG
- (NSString *)description {
    NSMutableString *str = [NSMutableString string];
    [str appendString:@"Simulator\n"];
    [str appendFormat:@" bundle resource path: %@\n",[[NSBundle mainBundle] resourcePath]];
    return str;
}
#endif

@end

#endif // TARGET_IPHONE_SIMULATOR

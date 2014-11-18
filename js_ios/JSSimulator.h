#if TARGET_IPHONE_SIMULATOR

@interface JSSimulator : NSObject

+ (JSSimulator *)sharedInstance;

// Exposed for unit tests
+ (NSString *)getNewFilesDirectoryName;

// Print the path where files will be written to (to aid in
// determining simbuddy's simulator directory argument)
+ (void)printPath;

// Returns nil if error occurs
- (NSString *)resourcePath:(NSString *)relativeResourcePath forWriting:(BOOL)forWriting error:(NSError **)error;
- (NSString *)readStringFrom:(NSString *)relativeResourcePath error:(NSError **)error;
- (BOOL)writeString:(NSString *)string toResourcePath:(NSString *)relativeResourcePath error:(NSError **)error;

@property (nonatomic, copy) NSString *appResourcesPath;
@property (nonatomic, copy) NSString *filesDumpPath;

@end

#endif


@interface NSString (JSStringUtil_NSStringCategory)

// Note: if substring is empty, this always returns false
- (BOOL) containsString: (NSString*)substring;
- (int) indexOf:(NSString *)substring mustExist:(BOOL)mustExist;
- (int) indexOf:(NSString *)substring;
- (BOOL) writeToPath:(NSString *)path error:(NSError **)error;
- (BOOL) writeToPath:(NSString *)path onlyIfChanged:(BOOL)onlyIfChanged error:(NSError **)error;
+ (NSString *)readFromPath:(NSString *)p defaultContents:(NSString *)s error:(NSError **)error;
+ (NSString *)readFromPath:(NSString *)p error:(NSError **)error;
- (NSArray *)extractTokens;
- (NSString *)trimWhitespace;
// Returns true if string ends with whitespace (or is empty)
- (BOOL) endsWithWhitespace;
- (NSString *)stringByReplacingPathExtensionWith:(NSString *)ext;
#if DEBUG
- (NSString *)objcString;
#endif

@end

@interface NSArray ( JSArrayCategory )

- (BOOL) isEmpty;

@end


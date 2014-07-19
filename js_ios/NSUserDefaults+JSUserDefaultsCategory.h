#define NSStandardUserDefaults [NSUserDefaults standardUserDefaults]

@interface NSUserDefaults (JSUserDefaultsCategory)

- (id)objectForKey:(NSString *)key or:(id)v;
- (NSString *)stringForKey:(NSString *)key or:(NSString *)v;
- (NSInteger)integerForKey:(NSString *)key or:(NSInteger)v;
- (CGFloat)floatForKey:(NSString *)key or:(CGFloat)v;
- (BOOL)boolForKey:(NSString *)key or:(BOOL)v;
+ (void)setSynchronizeDelay:(NSTimeInterval)delay;

@end

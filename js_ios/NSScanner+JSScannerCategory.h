#if DEBUG


@interface NSScanner (JSScannerCategory)

- (int)getInt;
- (int)getHex;
- (double)getDouble;
- (BOOL)getBool;
- (void)getTag:(NSString *)tag;
- (void)toss:(NSString *)formatString, ...;

@end

#endif

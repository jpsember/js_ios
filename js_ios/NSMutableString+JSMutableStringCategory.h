@interface NSMutableString (JSMutableStringCategory)

- (void)clear;
// Truncate to a particular length, if greater than it
- (void)truncateToLength:(int)length;

@end

#import <GLKit/GLKit.h>

@interface GLTools2 : NSObject

+ (void)setGLColor:(UIColor *)uiColor;
+ (void)setGLColor:(UIColor *)uiColor destination:(GLfloat *)dest;

@end

#if DEBUG
// Convenience methods to display non-class objects as strings
#define dRect(rect) [DebugTools dRect:rect]
#define dPoint(point) [DebugTools dPoint:point]
#define dDouble(value) [DebugTools dDouble:value format:nil]
NSString *dFloats(const float *array, int len);
NSString *dBytes(const byte *array, int len);
NSString *dImage(UIImage *image);
#endif

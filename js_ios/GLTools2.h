#import <GLKit/GLKit.h>

@interface GLTools2 : NSObject

+ (void)setGLColor:(UIColor *)uiColor;
+ (void)setGLColor:(UIColor *)uiColor destination:(GLfloat *)dest;

@end

#if DEBUG
// Convenience methods to display non-class objects as strings
NSString *dPoint(CGPoint pt);
NSString *dRect(CGRect rect);
NSString *dFloats(const float *array, int len);
NSString *dBytes(const byte *array, int len);
NSString *dImage(UIImage *image);
#endif

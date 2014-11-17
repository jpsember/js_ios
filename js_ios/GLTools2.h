#import <GLKit/GLKit.h>

@interface GLTools2 : NSObject

+ (void)setGLColor:(UIColor *)uiColor;
+ (GLuint)installTexture:(UIImage *)image size:(CGPoint *)sizePtr;

@end

#if DEBUG
NSString *dPoint(CGPoint pt);
NSString *dRect(CGRect rect);
NSString *dFloats(const float *array, int len);
NSString *dBytes(const byte *array, int len);
#endif

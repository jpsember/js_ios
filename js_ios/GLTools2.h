#import <GLKit/GLKit.h>

@interface GLTools2 : NSObject

+ (void)setGLColor:(UIColor *)uiColor;

@end

#if DEBUG
NSString *dPoint(CGPoint pt);
NSString *dRect(CGRect rect);
NSString *dFloats(const float *array, int len);
#endif

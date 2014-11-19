#import <GLKit/GLKit.h>

@interface GLTools : NSObject

+ (void)setGLColor:(UIColor *)uiColor;
+ (void)setGLColor:(UIColor *)uiColor destination:(GLfloat *)dest;

@end


#import "js_ios-Swift.h"
#import "JSBase.h"
#import "GLTools.h"

@implementation GLTools

+ (void)setGLColor:(UIColor *)uiColor {
  const CGFloat *c = CGColorGetComponents(uiColor.CGColor);
  glColor4f(c[0],c[1],c[2],c[3]);
}

+ (void)setGLColor:(UIColor *)uiColor destination:(GLfloat *)dest {
  const CGFloat *c = CGColorGetComponents(uiColor.CGColor);
  memcpy(dest,c,sizeof(GLfloat) * 4);
}

@end



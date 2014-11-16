#import "JSBase.h"
#import "GLTools2.h"
#import "js_ios-Swift.h"
#import <OpenGLES/EAGL.h>

@implementation GLTools2

+ (void)setGLColor:(UIColor *)uiColor {
  const CGFloat *components = CGColorGetComponents(uiColor.CGColor);
	CGFloat red = components[0];
	CGFloat green = components[1];
	CGFloat blue = components[2];
	CGFloat alpha = components[3];
	glColor4f(red,green, blue, alpha);
}
@end

#if DEBUG
NSString *dPoint(CGPoint pt) {
  return [NSString stringWithFormat:@"(%5.2f %5.2f) ",pt.x,pt.y];
}

NSString *dRect(CGRect rect) {
  return [NSString stringWithFormat:@"(x:%5.2f y:%5.2f w:%5.2f h:%5.2f) ",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height];
}

NSString *dFloats(const float *array, int len) {
  NSMutableString *s = [NSMutableString string];
  for (int i = 0; i < len; i++) {
    [s appendFormat:@"%7.4f ",array[i]];
    if ((i+1)%4 == 0)
      [s appendString:@"\n"];
  }
  return s;
}

#endif


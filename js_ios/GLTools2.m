#import "JSBase.h"
#import "GLTools2.h"
#import "js_ios-Swift.h"
#import <OpenGLES/EAGL.h>

@implementation GLTools2

+ (void)setGLColor:(UIColor *)uiColor {
  const CGFloat *c = CGColorGetComponents(uiColor.CGColor);
  glColor4f(c[0],c[1],c[2],c[3]);
}

+ (void)setGLColor:(UIColor *)uiColor destination:(GLfloat *)dest {
  const CGFloat *c = CGColorGetComponents(uiColor.CGColor);
  memcpy(dest,c,sizeof(GLfloat) * 4);
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
    [s appendString:dDouble(array[i])];
    if ((i+1)%4 == 0)
      [s appendString:@"\n"];
  }
  return s;
}

NSString *dBytes(const byte *array, int len) {
  NSMutableString *s = [NSMutableString string];
  for (int i = 0; i < len; i++) {
    [s appendFormat:@"%02x ",array[i]];
    if ((i+1)%4 == 0)
      [s appendString:@" "];
    if ((i+1)%32 == 0)
      [s appendString:@"\n"];
  }
  return s;
}

NSString *dImage(UIImage *image) {
  CGImageRef spriteImage = image.CGImage;
  CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(spriteImage));
  const byte *pixels = CFDataGetBytePtr(data);
  int length = CFDataGetLength(data);
  int dumpedLength = MIN(length, 32*4);
  NSMutableString *s = [NSMutableString string];
  [s appendFormat:@"UIImage %d x %d:\n%@\n",
   (int)image.size.width,(int)image.size.height,dBytes(pixels,dumpedLength)];
  return s;
}

NSString *dDouble(double x) {
  return [NSString stringWithFormat:@"%8.2f ",x];
}

NSString *dDoubleWith(double x, int width, int nDecimals) {
  NSString *fmt = [NSString stringWithFormat:@"%d.%d ",width,nDecimals];
  return [NSString stringWithFormat:fmt,x];
}

#endif


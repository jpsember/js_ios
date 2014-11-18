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

#endif


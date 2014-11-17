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

+ (void)exploreImage:(UIImage *)image {
  DBG
  CGImageRef spriteImage = image.CGImage;
  ASSERT(spriteImage,@"problem");
  
  CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(spriteImage));
  const byte *pixels = CFDataGetBytePtr(data);
  pr(@"Image %@, bytes:\n%@\n",image,dBytes(pixels, 128*64*4));
}

+ (GLuint)installTexture:(UIImage *)image size:(CGPoint *)sizePtr {
  DBG
  NSError *error = nil;
  if (false) [GLTools2 exploreImage:image];
  GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:nil error:&error];
  ASSERT(!error,@"failed to install texture: %@",error);
  *sizePtr = CGPointMake(textureInfo.width, textureInfo.height);
  pr(@"installTexture info:\n%@\n",textureInfo);
  
  return textureInfo.name;
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

#endif


#import "js_ios-Swift.h"
#import "JSBase.h"
#import "GLTools.h"

@implementation GLTools

+ (NSMutableArray *)deleteTextureIdList {
  static NSMutableArray *sDeleteTextureIds;
  if (sDeleteTextureIds == nil) {
    sDeleteTextureIds = [NSMutableArray array];
  }
  return sDeleteTextureIds;
}

+ (void)addIdToTextureDeleteList:(GLuint)textureId {
  [[GLTools deleteTextureIdList] addObject:@(textureId)];
}

+ (void)flushTextureDeleteList {
  NSMutableArray *a = [GLTools deleteTextureIdList];
  if ([a isEmpty]) {
    return;
	}
  [Texture dbMessage:[NSString stringWithFormat:@"flushTextureDeleteList, deleting %@",a]];

  GLuint b[a.count];
  for (int i = 0 ; i < a.count; i++) {
    b[i] = [a[i] integerValue];
  }
  glDeleteTextures(a.count, b);
  [a removeAllObjects];
}

+ (void)setGLColor:(UIColor *)uiColor {
  const CGFloat *c = CGColorGetComponents(uiColor.CGColor);
  glColor4f(c[0],c[1],c[2],c[3]);
}

+ (void)setGLColor:(UIColor *)uiColor destination:(GLfloat *)dest {
  const CGFloat *c = CGColorGetComponents(uiColor.CGColor);
  memcpy(dest,c,sizeof(GLfloat) * 4);
}

+ (NSString *)dumpBuffer {
  [GLTools verifyNoError];
  
  // This seems to be the only accepted format for glReadPixels
  GLenum pixelFormat = GL_RGBA;
  
  NSMutableString *s = [NSMutableString stringWithFormat:@"Dump of buffer:\n"];
  
  int w = 8;
  int h = 4;
  int bytesPerPixel = (pixelFormat == GL_RGBA) ? 4 : 3;
  int size = w*h*bytesPerPixel;
  byte data[size];
  memset(data,0xfe,size);
  
  glReadPixels(10,10,w,h, pixelFormat,GL_UNSIGNED_BYTE,data);
  [GLTools verifyNoError];

  int compCount = 0;
  int pixelCount = 0;
  for (int i = 0; i < size; i++) {
    byte b = data[i];
    if (b == 0)
      [s appendString:@"-- "];
    else
      [s appendFormat:@"%02x ",b];
    compCount++;
    if (compCount == bytesPerPixel) {
      compCount = 0;
      [s appendString:@"  "];
      pixelCount++;
      if (pixelCount % 8 == 0) {
        [s appendString:@"\n"];
      }
    }
  }
  return s;
}


@end



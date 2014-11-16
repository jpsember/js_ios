#import "JSBase.h"
#import "CTools.h"
#import "js_ios-Swift.h"
#import <OpenGLES/EAGL.h>

static GLfloat *vertBuffer = NULL;
static int vertBufferCapacity = 0;

@implementation CTools

+ (void)callA {
  A *a = [[A alloc] init];
  int q = [a doSomething:@"hey there"];
  DBG
  pr(@"a = %@; returned %d\n",a,q);
}

+ (void)argh:(NSArray *)array f:(int)f {
//  GLTools *tools = nil;
}

+ (void)prepareSpriteContext:(GLfloat *)vertexData nFloats:(int)nFloats
            positionLocation:(int)positionLocation
        textureCoordinateLocation:(int)textureCoordinateLocation {
  DBG
  pr(@"preparing vertexData %p\n",vertexData);
  
  warning(@"not finished yet");
  
  if (!vertBuffer || vertBufferCapacity < nFloats) {
    if (vertBuffer) free(vertBuffer);
    vertBufferCapacity = nFloats;
    vertBuffer = malloc(sizeof(CGFloat) * nFloats);
  }
  
  memcpy(vertBuffer, vertexData, sizeof(GLfloat) * nFloats);
  
  int POSITION_COMPONENT_COUNT = 2;
  int TEXTURE_COMPONENT_COUNT = 2;
  int stride = 2 /*TOTAL_COMPONENTS*/ * sizeof(GLfloat);
  
   glVertexAttribPointer(positionLocation, POSITION_COMPONENT_COUNT,
   	GL_FLOAT, false, stride, vertBuffer);
   glEnableVertexAttribArray(positionLocation);
   
   glVertexAttribPointer(textureCoordinateLocation,
   	TEXTURE_COMPONENT_COUNT, GL_FLOAT, false, stride, vertBuffer + POSITION_COMPONENT_COUNT);
   glEnableVertexAttribArray(textureCoordinateLocation);
   glDrawArrays(GL_TRIANGLES, 0, 6);
}


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


#import <GLKit/GLKit.h>

@class SpriteContext;

@interface CTools : NSObject

+ (void)callA;

+ (void)prepareSpriteContext:(GLfloat *)vertexData nFloats:(int)nfloats
            positionLocation:(int)positionLocation
        textureCoordinateLocation:(int)textureCoordinateLocation;

+ (void)setGLColor:(UIColor *)uiColor;

@end
#if DEBUG
NSString *dPoint(CGPoint pt);
NSString *dRect(CGRect rect);
NSString *dFloats(const float *array, int len);
#endif


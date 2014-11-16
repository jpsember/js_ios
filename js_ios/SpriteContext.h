#import <OpenGLES/EAGL.h>
#import <UIKit/UIKit.h>

@class Renderer;
@class Texture;

@interface SpriteContext : NSObject

+ (SpriteContext *)spriteContextWithTransformName:(NSString *)transformName tintMode:(BOOL)tintMode;
+ (void)prepare:(Renderer *)renderer;
+ (SpriteContext *)normalContext;
- (int)projectionMatrixId;
- (void)setProjectionMatrixId:(int)matrixId;
- (void)setTintColor:(UIColor *)color;
- (void)renderSprite:(Texture *)texture vertexData:(GLfloat *)vertexData dataLength:(NSInteger)length position:(CGPoint)position;
- (void)activateProgram;
- (void)prepareProgram;
- (void)prepareAttributes;
- (void)prepareProjection;

@end

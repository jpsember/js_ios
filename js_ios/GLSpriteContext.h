#import <UIKit/UIKit.h>

#define POSITION_COMPONENT_COUNT 2
#define TEXTURE_COMPONENT_COUNT 2

#define POSITION_COMPONENT_OFFSET 0
#define TEXTURE_COMPONENT_OFFSET 2
#define TOTAL_COMPONENTS 4

#define TOTAL_VERTICES 6

@class Renderer;
@class Texture;

@interface GLSpriteContext : NSObject

+ (GLSpriteContext *)spriteContextWithTransformName:(NSString *)transformName tintMode:(BOOL)tintMode;
+ (void)prepare:(Renderer *)renderer;
+ (GLSpriteContext *)normalContext;
- (void)setTintColor:(UIColor *)color;
- (void)renderSprite:(Texture *)texture vertexData:(GLfloat *)vertexData dataLength:(NSInteger)length position:(CGPoint)position;
- (void)activateProgram;
- (void)prepareProgram;
- (void)prepareAttributes;
- (void)prepareProjection;

@end

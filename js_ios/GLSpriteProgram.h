#import <UIKit/UIKit.h>

#define POSITION_COMPONENT_COUNT 2
#define TEXTURE_COMPONENT_COUNT 2

#define POSITION_COMPONENT_OFFSET 0
#define TEXTURE_COMPONENT_OFFSET 2
#define TOTAL_COMPONENTS 4

#define TOTAL_VERTICES 6

@class Renderer;
@class Texture;

@interface GLSpriteProgram : NSObject

+ (GLSpriteProgram *)spriteProgramWithTransformName:(NSString *)transformName tintMode:(BOOL)tintMode;
+ (void)prepare:(Renderer *)renderer;
+ (GLSpriteProgram *)normalProgram;

- (void)setTintColor:(UIColor *)color;
- (void)renderSprite:(Texture *)texture vertexData:(GLfloat *)vertexData dataLength:(NSInteger)length position:(CGPoint)position;

@end

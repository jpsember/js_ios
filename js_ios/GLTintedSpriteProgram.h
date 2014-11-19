#import "GLSpriteProgram.h"

@interface GLTintedSpriteProgram : GLSpriteProgram

+ (GLTintedSpriteProgram *)programWithTransformName:(NSString *)transformName;
+ (void)prepare:(Renderer *)renderer;
+ (GLTintedSpriteProgram *)program;

- (id)initWithTransformName:(NSString *)transformName;

- (void)setTintColor:(UIColor *)color;

@end

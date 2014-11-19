#import "GLSpriteProgram.h"

@interface GLTintedSpriteProgram : GLSpriteProgram

+ (GLTintedSpriteProgram *)getProgram;

+ (void)prepare:(Renderer *)renderer;

- (void)setTintColor:(UIColor *)color;

@end

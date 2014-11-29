#import "GLSpriteProgram.h"

@interface GLTintedSpriteProgram : GLSpriteProgram

@property (nonatomic, strong) UIColor *tintColor;

+ (GLTintedSpriteProgram *)getProgram;
+ (void)prepare:(Renderer *)renderer;

@end

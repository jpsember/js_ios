#import <OpenGLES/EAGL.h>
#import <UIKit/UIKit.h>
#import "GLSpriteContext.h"

@interface GLSpriteProgram : NSObject

- (id)initWithContext:(GLSpriteContext *)context texture:(Texture *)texture window:(CGRect)textureWindow;
/**
 * Initialize with window that encompasses the entire texture
 */
- (id)initWithContext:(GLSpriteContext *)context texture:(Texture *)texture;
- (void)setPosition:(CGPoint)pos;
- (void)setPosition:(CGFloat)x y:(CGFloat)y;
- (void)render;

@end

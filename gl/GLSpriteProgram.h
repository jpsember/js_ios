#import <OpenGLES/EAGL.h>
#import <UIKit/UIKit.h>
#import "SpriteContext.h"

@interface GLSpriteProgram : NSObject

- (id)initWithContext:(SpriteContext *)context texture:(Texture *)texture window:(CGRect)textureWindow;
- (void)setPosition:(CGPoint)pos;
- (void)setPosition:(CGFloat)x y:(CGFloat)y;
- (void)render;

@end

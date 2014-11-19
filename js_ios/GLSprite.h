#import <UIKit/UIKit.h>
#import "GLSpriteProgram.h"

@interface GLSprite : NSObject

/**
 * Designated initializer
 * If program is nil, uses basic program
 */
- (id)initWithTexture:(Texture *)texture window:(CGRect)textureWindow program:(GLSpriteProgram *)program;

// Render sprite at a location
//
- (void)render:(CGPoint)position;

@end

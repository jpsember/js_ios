#import <UIKit/UIKit.h>
#import "GLSpriteProgram.h"

@interface GLSprite : NSObject

- (id)initWithProgram:(GLSpriteProgram *)program texture:(Texture *)texture window:(CGRect)textureWindow;

/**
 * Initialize with window that encompasses the entire texture
 */
- (id)initWithProgram:(GLSpriteProgram *)program texture:(Texture *)texture;

// Render sprite at a location
//
- (void)render:(CGPoint)position;

@end

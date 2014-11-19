#import <UIKit/UIKit.h>
#import "GLSpriteContext.h"

@interface GLSprite : NSObject

- (id)initWithContext:(GLSpriteContext *)context texture:(Texture *)texture window:(CGRect)textureWindow;

/**
 * Initialize with window that encompasses the entire texture
 */
- (id)initWithContext:(GLSpriteContext *)context texture:(Texture *)texture;

// Render sprite at a location
//
- (void)render:(CGPoint)position;

@end

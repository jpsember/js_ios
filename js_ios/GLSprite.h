#import <UIKit/UIKit.h>
#import "GLSpriteProgram.h"

@interface GLSprite : NSObject

@property (nonatomic, readonly, strong) Texture *texture;
@property (nonatomic, assign) CGFloat scale;

/**
 * Designated initializer
 * If program is nil, uses basic program
 */
- (id)initWithTexture:(Texture *)texture window:(CGRect)textureWindow program:(GLSpriteProgram *)program;

// Render sprite at a location
//
- (void)render:(CGPoint)position;

@end

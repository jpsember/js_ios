#import <UIKit/UIKit.h>

// Vertices per sprite (two triangles * 3 verts per)
#define TOTAL_VERTICES 6

// Number of floats for vertex fields
#define POSITION_COMPONENT_COUNT 2
#define TEXTURE_COMPONENT_COUNT 2
#define TOTAL_COMPONENTS (POSITION_COMPONENT_COUNT + TEXTURE_COMPONENT_COUNT)

@class Renderer;
@class Texture;

@interface GLSpriteProgram : NSObject

// Prepare the program instances for use with a renderer
+ (void)prepare:(Renderer *)renderer;

// Get the singleton program instance (at present, there's only one)
// Note we add the prefix 'get' to satisfy the compiler (otherwise it thinks it's a constructor)
+ (GLSpriteProgram *)getProgram;

- (void)renderSprite:(Texture *)texture vertexData:(GLfloat *)vertexData dataLength:(NSInteger)length position:(CGPoint)position;

// Exposed for subclass use only
- (id)initWithTransformName:(NSString *)transformName;
- (NSString *)fragmentShaderName;
- (void)renderAux;
- (void)prepareAttributes;

@end

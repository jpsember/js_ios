#import "js_ios-Swift.h"
#import "GLSprite.h"

@interface GLSprite ()
{
	GLfloat _vertexInfo[TOTAL_VERTICES * TOTAL_COMPONENTS];
}

@property (nonatomic, assign) CGRect textureWindow;
@property (nonatomic, strong) GLSpriteProgram *program;
@property (nonatomic, assign) BOOL vertexInfoValid;

@end


@implementation GLSprite

/**
 * Initialize with window that encompasses the entire texture
 */
- (id)initWithTexture:(Texture *)texture window:(CGRect)textureWindow program:(GLSpriteProgram *)program {
  if (self = [super init]) {
    if (program == nil)
      program = [GLSpriteProgram getProgram];
    _program = program;
    _texture = texture;
    _textureWindow = textureWindow;
    _vertexInfoValid = NO;
    _scale = 1.0;
  }
  return self;
}

- (void)setScale:(CGFloat)scale {
  if (scale != _scale) {
    _scale = scale;
    _vertexInfoValid = NO;
  }
}

- (void)constructVertexInfo {
  
  CGPoint p0 = CGPointMake(0,0);
  CGPoint p2 = CGPointMake(_textureWindow.size.width * self.scale,_textureWindow.size.height * self.scale);
  CGPoint p1 = CGPointMake(p2.x,p0.y);
  CGPoint p3 = CGPointMake(p0.x,p2.y);
  
  // Textures loaded from xxx.png have been flipped vertically, and those generated
  // by rendering to FBO have a similarly flipped orientation
  
  CGPoint  t3 = CGPointMake(_textureWindow.origin.x /  [self.texture width],
                            CGRectGetMaxY(_textureWindow) /  [_texture height] );
  CGPoint  t1 = CGPointMake(CGRectGetMaxX(_textureWindow) /  [self.texture width],
                            _textureWindow.origin.y /  [_texture height]);
  CGPoint  t2 = CGPointMake(t1.x, t3.y);
  CGPoint  t0 = CGPointMake(t3.x, t1.y);
  
  int cursor = 0;
#undef M
#define M(pt) {_vertexInfo[cursor] = pt.x; _vertexInfo[cursor+1] = pt.y; cursor += 2;}
  M(p0);M(t0);M(p1);M(t1);M(p2);M(t2);
  M(p0);M(t0);M(p2);M(t2);M(p3);M(t3);
#undef M
  
  self.vertexInfoValid = YES;
}

- (void)render:(CGPoint)position {
  
  if (!self.vertexInfoValid) {
    [self constructVertexInfo];
  }
  
  [self.program renderSprite:self.texture vertexData:_vertexInfo
                  dataLength:(TOTAL_VERTICES * TOTAL_COMPONENTS)
                    position:position];
}

@end

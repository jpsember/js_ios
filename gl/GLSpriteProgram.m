#import "JSBase.h"
#import "GLSpriteProgram.h"
#import "js_ios-Swift.h"
#import "GLTools2.h"

@interface GLSpriteProgram ()
{
    GLfloat _vertexInfo[TOTAL_VERTICES * TOTAL_COMPONENTS];
}

@property (nonatomic, strong) Texture *texture;
@property (nonatomic, assign) CGRect textureWindow;
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, strong) GLSpriteContext *context;

@end


@implementation GLSpriteProgram

- (id)initWithContext:(GLSpriteContext *)context texture:(Texture *)texture window:(CGRect)textureWindow {
  if (self = [super init]) {
    _context = context;
    _texture = texture;
    _textureWindow = textureWindow;
    [self constructVertexInfo];
  }
  return self;
}

- (void)setPosition:(CGPoint)pos {
  [self setPosition:pos.x y:pos.y];
}

- (void)setPosition:(CGFloat)x y:(CGFloat)y {
  _position = CGPointMake(x,y);
}

- (void)constructVertexInfo {
  
  CGPoint p0 = CGPointMake(0,0);
  CGPoint p2 = CGPointMake(_textureWindow.size.width,_textureWindow.size.height);
  CGPoint p1 = CGPointMake(p2.x,p0.y);
  CGPoint p3 = CGPointMake(p0.x,p2.y);
  
  CGPoint  t0 = CGPointMake(_textureWindow.origin.x /  [self.texture width],
                            CGRectGetMaxY(_textureWindow) /  [_texture height] );
  CGPoint  t2 = CGPointMake(CGRectGetMaxX(_textureWindow) /  [self.texture width],
                            _textureWindow.origin.y /  [_texture height]);
  CGPoint  t1 = CGPointMake(t2.x, t0.y);
  CGPoint  t3 = CGPointMake(t0.x, t2.y);
  
  int cursor = 0;
#undef M
#define M(pt) {_vertexInfo[cursor] = pt.x; _vertexInfo[cursor+1] = pt.y; cursor += 2;}
  M(p0);M(t0);M(p1);M(t1);M(p2);M(t2);
  M(p0);M(t0);M(p2);M(t2);M(p3);M(t3);
#undef M
}

- (void)render {
  [self.context renderSprite:self.texture vertexData:_vertexInfo
                  dataLength:(TOTAL_VERTICES * TOTAL_COMPONENTS)
                    position:self.position];
}

@end

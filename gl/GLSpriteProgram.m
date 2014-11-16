#import "JSBase.h"
#import "GLSpriteProgram.h"
#import "js_ios-Swift.h"
#import "CTools.h"

// Two coordinates for position; two coordinates for texture; 4 floats per vertex
#define POSITION_COMPONENT_COUNT 2
#define TEXTURE_COMPONENT_COUNT 2
#define TOTAL_COMPONENTS (POSITION_COMPONENT_COUNT + TEXTURE_COMPONENT_COUNT)
#define TOTAL_VERTICES 6

@interface GLSpriteProgram ()
{
    GLfloat _vertexInfo[TOTAL_VERTICES * TOTAL_COMPONENTS];
}

@property (nonatomic, strong) Texture *texture;
@property (nonatomic, assign) CGRect textureWindow;
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, strong) SpriteContext *context;

@end


@implementation GLSpriteProgram


- (id)initWithContext:(SpriteContext *)context texture:(Texture *)texture window:(CGRect)textureWindow {
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
  //DBG
  CGPoint p0 = CGPointMake(0,0);
  CGPoint p2 = CGPointMake(_textureWindow.size.width,_textureWindow.size.height);
  CGPoint p1 = CGPointMake(p2.x,p0.y);
  CGPoint p3 = CGPointMake(p0.x,p2.y);
  
  pr(@"textureWindow = %@\n",dRect(_textureWindow));
  pr(@" texture width %d\n",[self.texture width]);
  pr(@" texture height %d\n",[self.texture height]);
  pr(@" getRectMaxY %f\n",CGRectGetMaxY(_textureWindow) );
  pr(@" getRectMaxX %f\n",CGRectGetMaxX(_textureWindow) );
  
  CGPoint  t0 = CGPointMake(_textureWindow.origin.x /  [self.texture width],
                            CGRectGetMaxY(_textureWindow) /  [_texture height] );
  CGPoint  t2 = CGPointMake(CGRectGetMaxX(_textureWindow) /  [self.texture width],
                            _textureWindow.origin.y /  [_texture height]);
  
  CGPoint  t1 = CGPointMake(t2.x, t0.y);
  CGPoint  t3 = CGPointMake(t0.x, t2.y);
  pr(@" t0=%@\n",dPoint(t0));
  pr(@" t1=%@\n",dPoint(t1));
  pr(@" t2=%@\n",dPoint(t2));
  pr(@" t3=%@\n",dPoint(t3));

  pr(@"constructVertexInfo\n");
  
  int cursor = 0;
#undef ap
#define ap(pt) {_vertexInfo[cursor] = pt.x; _vertexInfo[cursor+1] = pt.y; cursor += 2;}
  ap(p0);
  ap(t0);
  ap(p1);
  ap(t1);
  ap(p2);
  ap(t2);
  
  ap(p0);
  ap(t0);
  ap(p2);
  ap(t2);
  ap(p3);
  ap(t3);
}

- (void)render {
  [self.context renderSprite:self.texture vertexData:_vertexInfo
                  dataLength:(TOTAL_VERTICES * TOTAL_COMPONENTS)
                    position:self.position];
}

@end

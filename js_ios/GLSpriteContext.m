#import "js_ios-Swift.h"
#import "JSBase.h"
#import "GLSpriteContext.h"
#import "GLTools.h"

static id spriteContext;
static Renderer *renderer;
static GLSpriteContext *normalContext;

@interface GLSpriteContext ()
{
  GLfloat _tintColor[4];
}

@property (nonatomic, strong) NSString *transformName;
@property (nonatomic, assign) BOOL tintMode;

@property (nonatomic, assign) int preparedProjectionMatrixId;
@property (nonatomic, assign) int preparedSurfaceId;
@property (nonatomic, assign) int programObjectId;
@property (nonatomic, assign) int positionLocation ;
@property (nonatomic, assign) int textureCoordinateLocation;
@property (nonatomic, assign) int matrixLocation;
@property (nonatomic, assign) int spritePositionLocation;
@property (nonatomic, assign) int colorLocation;

@property (nonatomic, strong) Shader *vertexShader;
@property (nonatomic, strong) Shader *fragmentShader;

@end

@implementation GLSpriteContext

- (int)projectionMatrixId {
  return [renderer projectionMatrixId];
}

+ (GLSpriteContext *)spriteContextWithTransformName:(NSString *)transformName tintMode:(BOOL)tintMode {
  return [[GLSpriteContext alloc] initWithTransformName:transformName tintMode:tintMode];
}

- (id)initWithTransformName:(NSString *)transformName tintMode:(BOOL)tintMode {

  if (self = [super init]) {
    _transformName = transformName;
    _tintMode = tintMode;
  }
  return self;
}

- (void)setTintColor:(UIColor *)color {
  ASSERT(self.tintMode,@"expected tint mode");
  [GLTools setGLColor:color destination:_tintColor];
}

- (void)prepareShaders {
  self.vertexShader = [Shader readVertexShader:@"vertex_shader_texture.glsl"];
  self.fragmentShader = [Shader readFragmentShader:(self.tintMode ? @"fragment_shader_mask.glsl" : @"fragment_shader_texture.glsl")];
}

+ (void)prepare:(Renderer *)r {
  renderer = r;
  normalContext = [GLSpriteContext spriteContextWithTransformName:[Renderer transformNameDeviceToNDC] tintMode:NO];
}

+ (GLSpriteContext *)normalContext {
  return normalContext;
}


- (void)renderSprite:(Texture *)texture vertexData:(GLfloat *)vertexData dataLength:(int)length position:(CGPoint)position {
  
  [self activateProgram];
  [self prepareProjection];
  
  glUniform2f(self.spritePositionLocation, position.x,position.y);
  
  if (self.tintMode) {
    glUniform4fv(self.colorLocation, 1, _tintColor);
  }
  
  [texture select];
  
  int stride = TOTAL_COMPONENTS * sizeof(GLfloat);
  
  glVertexAttribPointer(self.positionLocation, POSITION_COMPONENT_COUNT, GL_FLOAT, false, stride, vertexData);
  glEnableVertexAttribArray(self.positionLocation);
  
  glVertexAttribPointer(self.textureCoordinateLocation, TEXTURE_COMPONENT_COUNT, GL_FLOAT, false, stride, vertexData + POSITION_COMPONENT_COUNT);
  glEnableVertexAttribArray(self.textureCoordinateLocation);
  
  glDrawArrays(GL_TRIANGLES, 0, 6);
  [GLTools verifyNoError];
  
}

- (void)activateProgram {
  if (self.preparedSurfaceId == 0) {
    self.preparedSurfaceId = 1;
    [self prepareShaders];
    [self prepareProgram];
  }
  glUseProgram(self.programObjectId);
}

- (void)prepareProgram {
  self.programObjectId = [GLTools createProgram];
  glAttachShader(self.programObjectId, [self.vertexShader getId]);
  glAttachShader(self.programObjectId, [self.fragmentShader getId]);
  [GLTools linkProgram:self.programObjectId];
  [GLTools validateProgram:self.programObjectId];
  [self prepareAttributes];
}

- (void)prepareAttributes {
  [GLTools setProgram:self.programObjectId];
  self.positionLocation = [GLTools getProgramLocation:@"a_Position"];
  self.spritePositionLocation = [GLTools getProgramLocation:@"u_SpritePosition"];
  self.textureCoordinateLocation = [GLTools getProgramLocation:@"a_TexCoordinate"];
  self.matrixLocation = [GLTools getProgramLocation:@"u_Matrix"];
  if (self.tintMode) {
    self.colorLocation = [GLTools getProgramLocation:@"u_InputColor"];
  }
}

- (void)prepareProjection {
  int currentProjectionMatrixId = [self projectionMatrixId];
  if (currentProjectionMatrixId == self.preparedProjectionMatrixId) {
    return;
  }
  _preparedProjectionMatrixId = currentProjectionMatrixId;
  
  // Transform 2D screen->NDC matrix to a 3D version
  CGAffineTransform matrix = [renderer getTransform:self.transformName];
  GLfloat matrix44[] = {
    matrix.a, matrix.b,0,0,//
    matrix.c,matrix.d,0,0,//
    0,0,1,0,//
    matrix.tx,matrix.ty,0,1 //
  };
  glUniformMatrix4fv(self.matrixLocation,1,NO, matrix44);
}

@end


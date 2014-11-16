#import <OpenGLES/EAGL.h>
#import "JSBase.h"
#import "SpriteContext.h"
#import "js_ios-Swift.h"
#import "CTools.h"

static int projectionMatrixId = -1;
static id spriteContext;
static Renderer *renderer;
static SpriteContext *normalContext;

@interface SpriteContext ()
{
  GLfloat _tintColor[4];
}

@property (nonatomic, strong) NSString *transformName;
@property (nonatomic, assign) BOOL tintMode;
#define POSITION_COMPONENT_COUNT 2
#define TEXTURE_COMPONENT_COUNT 2
#define TOTAL_COMPONENTS (POSITION_COMPONENT_COUNT + TEXTURE_COMPONENT_COUNT)

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

@implementation SpriteContext

- (int)projectionMatrixId {
  return projectionMatrixId;
}

- (void)setProjectionMatrixId:(int)matrixId {
  projectionMatrixId = matrixId;
}

+ (SpriteContext *)spriteContextWithTransformName:(NSString *)transformName tintMode:(BOOL)tintMode {
  return [[SpriteContext alloc] initWithTransformName:transformName tintMode:tintMode];
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
  [CTools setGLColor:color];
}

- (void)prepareShaders {
  self.vertexShader = [Shader readVertexShader:@"vertex_shader_texture.glsl"];
  self.fragmentShader = [Shader readFragmentShader:(self.tintMode ? @"fragment_shader_mask.glsl" : @"fragment_shader_texture.glsl")];
}

+ (void)prepare:(Renderer *)r {
  renderer = r;
  normalContext = [SpriteContext spriteContextWithTransformName:[Renderer transformNameDeviceToNDC] tintMode:NO];
}

+ (SpriteContext *)normalContext {
  return normalContext;
}

#define ARRAY 0

- (void)renderSprite:(Texture *)texture vertexData:(GLfloat *)vertexData dataLength:(int)length position:(CGPoint)position {
  DBG
  pr(@"renderSprite, texture %@ position %f,%f\n",texture,position.x,position.y);
  
  [self activateProgram];
  [self prepareProjection];
  
#if ARRAY
  for (int x = -20; x < 20; x++) {
    for (int y = -20; y < 20; y++) {
      position = CGPointMake(x*70,y*70);
#endif
      glUniform2f(self.spritePositionLocation, position.x,position.y);
      
      if (self.tintMode) {
        // Send one vec4 (the second parameter; this was a gotcha)
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
      
#if ARRAY
    }
  }
#endif
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
  ASSERT(renderer != nil,@"renderer is nil");
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
  //    DBG
  pr(@"prepareProjection\n");
  int currentProjectionMatrixId = projectionMatrixId;
  if (currentProjectionMatrixId == self.preparedProjectionMatrixId) {
    pr(@" unchanged, returning\n");
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
  pr(@" storing matrix:\n%@\n",dFloats(matrix44,16));
  glUniformMatrix4fv(self.matrixLocation,1,NO, matrix44);
}

@end


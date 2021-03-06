#import "js_ios-Swift.h"
#import "JSBase.h"
#import "GLSpriteProgram.h"
#import "TextureTools.h"

static GLSpriteProgram *program;

@interface GLSpriteProgram ()
{
  GLfloat _tintColor[4];
}

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

@implementation GLSpriteProgram

- (int)projectionMatrixId {
  return [[Renderer sharedInstance] projectionMatrixId];
}

+ (GLSpriteProgram *)program {
  return [[GLSpriteProgram alloc] init];
}

- (NSString *)fragmentShaderName {
  return @"fragment_shader_texture.glsl";
}

- (void)prepareShaders {
  self.vertexShader = [Shader readVertexShader:@"vertex_shader_texture.glsl"];
  self.fragmentShader = [Shader readFragmentShader:[self fragmentShaderName]];
}

+ (GLSpriteProgram *)getProgram {
  if (!program) {
    program = [GLSpriteProgram program];
  }
  return program;
}

- (void)renderSprite:(Texture *)texture vertexData:(GLfloat *)vertexData dataLength:(int)length position:(CGPoint)position {
  
  [self activateProgram];
  [self prepareProjection];
  
  glUniform2f(self.spritePositionLocation, position.x,position.y);
  
  [self renderAux];
  
  [texture select];
  
  // Enable blending iff texture has alpha channel
  // TODO: cache opengl state to avoid unnecessary calls here
  if (texture.hasAlpha) {
    glEnable(GL_BLEND);
  } else {
    glDisable(GL_BLEND);
  }
  
//  DBG
//  pr(@"renderSprite, vertexData=\n%@\n",dFloats(vertexData,length));
  
  int stride = TOTAL_COMPONENTS * sizeof(GLfloat);
  
  glVertexAttribPointer(self.positionLocation, POSITION_COMPONENT_COUNT, GL_FLOAT, false, stride, vertexData);
  glEnableVertexAttribArray(self.positionLocation);
  
  glVertexAttribPointer(self.textureCoordinateLocation, TEXTURE_COMPONENT_COUNT, GL_FLOAT, false, stride, vertexData + POSITION_COMPONENT_COUNT);
  glEnableVertexAttribArray(self.textureCoordinateLocation);
  
  glDrawArrays(GL_TRIANGLES, 0, 6);
  [GLTools verifyNoError];
  
}

- (void)renderAux {
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
  CGAffineTransform matrix = [[Renderer sharedInstance] transform];
  GLfloat matrix44[] = {
    matrix.a,matrix.b,0,0,//
    matrix.c,matrix.d,0,0,//
    0,0,1,0,//
    matrix.tx,matrix.ty,0,1 //
  };
//  DBG
//  pr(@"OpenGL matrix=\n%@\n",dTransform4(matrix44));
  glUniformMatrix4fv(self.matrixLocation,1,NO,matrix44);
}

@end


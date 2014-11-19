#import "js_ios-Swift.h"
#import "JSBase.h"
#import "GLTools.h"
#import "GLTintedSpriteProgram.h"

static id spriteContext;
static Renderer *renderer;
static GLTintedSpriteProgram *tintProgram;

@interface GLTintedSpriteProgram ()
{
  GLfloat _tintColor[4];
}

@property (nonatomic, assign) int colorLocation;

@end

@implementation GLTintedSpriteProgram

+ (GLTintedSpriteProgram *)programWithTransformName:(NSString *)transformName {
  return [[GLTintedSpriteProgram alloc] initWithTransformName:transformName];
}

- (id)initWithTransformName:(NSString *)transformName {
  if (self = [super initWithTransformName:transformName]) {
  }
  return self;
}

- (void)setTintColor:(UIColor *)color {
  [GLTools setGLColor:color destination:_tintColor];
}

- (NSString *)fragmentShaderName {
  return @"fragment_shader_mask.glsl";
}

+ (void)prepare:(Renderer *)r {
  renderer = r;
  tintProgram = [GLTintedSpriteProgram programWithTransformName:[Renderer transformNameDeviceToNDC]];
}

+ (GLTintedSpriteProgram *)program {
  return tintProgram;
}

- (void)renderAux {
  glUniform4fv(self.colorLocation, 1, _tintColor);
}

- (void)prepareAttributes {
  [super prepareAttributes];
  self.colorLocation = [GLTools getProgramLocation:@"u_InputColor"];
}


@end


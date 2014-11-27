#import "js_ios-Swift.h"
#import "JSBase.h"
#import "GLTintedSpriteProgram.h"

static GLTintedSpriteProgram *program;

@interface GLTintedSpriteProgram ()
{
  GLfloat _tintColor[4];
}

@property (nonatomic, assign) int colorLocation;

@end

@implementation GLTintedSpriteProgram

+ (GLTintedSpriteProgram *)program {
	return [[GLTintedSpriteProgram alloc] init];
}

- (void)setTintColor:(UIColor *)color {
  [GLTools setGLColor:color destination:_tintColor];
}

- (NSString *)fragmentShaderName {
  return @"fragment_shader_mask.glsl";
}

+ (void)prepare:(Renderer *)r {
}

+ (GLTintedSpriteProgram *)getProgram {
   if (!program) {
      program = [GLTintedSpriteProgram program];
   }
   return program;
}

- (void)renderAux {
  glUniform4fv(self.colorLocation, 1, _tintColor);
}

- (void)prepareAttributes {
  [super prepareAttributes];
  self.colorLocation = [GLTools getProgramLocation:@"u_InputColor"];
}


@end


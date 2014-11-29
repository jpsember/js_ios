#import "js_ios-Swift.h"
#import "JSBase.h"
#import "GLTintedSpriteProgram.h"

static GLTintedSpriteProgram *program;

@interface GLTintedSpriteProgram ()
@property (nonatomic, assign) int colorLocation;
@end

@implementation GLTintedSpriteProgram

+ (GLTintedSpriteProgram *)program {
	return [[GLTintedSpriteProgram alloc] init];
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
  if (_tintColor == nil) {
    warning(@"no tint color defined");
    return;
  }
  glUniform4fv(self.colorLocation, 1, CGColorGetComponents(self.tintColor.CGColor));
}

- (void)prepareAttributes {
  [super prepareAttributes];
  self.colorLocation = [GLTools getProgramLocation:@"u_InputColor"];
}

@end


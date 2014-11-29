#import "JSBase.h"
#import "TextureTools.h"
#import "GLBuffer.h"
#import "js_ios-Swift.h"

@interface GLBuffer()

@property (nonatomic, assign, readonly) GLint savedFBOIdentifier;
@end

@implementation GLBuffer

+ (GLBuffer *)bufferWithSize:(CGPoint)size hasAlpha:(BOOL)hasAlpha {
  
  GLBuffer *buffer = [[GLBuffer alloc] initWithSize:size hasAlpha:hasAlpha];
  return buffer;
  
}

- (id)initWithSize:(CGPoint)size hasAlpha:(BOOL)hasAlpha {
  if (self = [super init]) {
    _size = size;
    _hasAlpha = hasAlpha;
  }
  return self;
}

- (void)openRender {
  [GLTools pushNewFrameBuffer];
  
  _texture = [[Texture alloc] initWithSize:_size hasAlpha:_hasAlpha withRepeat:YES context:@"GLBuffer.openRender"];
  
  glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texture.textureId, 0);
  [GLTools verifyFrameBufferStatus];
}

- (void)closeRender {
  [GLTools popFrameBuffer];
}

@end

#import "JSBase.h"
#import "GLTools.h"
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
  
  _textureId = [GLTools createTexture:_size withAlphaChannel:_hasAlpha withRepeat:YES];
  
  glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textureId, 0);
  [GLTools verifyFrameBufferStatus];
}

- (void)closeRender {
  [GLTools popFrameBuffer];
}

@end

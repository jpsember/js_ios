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

  // I think this saves the current active framebuffer (i.e., rendering to GLKView)
  glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_savedFBOIdentifier);
  
  GLuint fboHandle;
  GLuint fboTex;
  
  glGenFramebuffers(1, &fboHandle);
  glGenTextures(1, &fboTex);
//  glGenRenderbuffers(1, &depthBuffer);
  _textureId = fboTex;
  
  glBindFramebuffer(GL_FRAMEBUFFER, fboHandle);
  
  glBindTexture(GL_TEXTURE_2D, fboTex);

  GLuint format = _hasAlpha ? GL_RGBA : GL_RGB;

  glTexImage2D( GL_TEXTURE_2D,
               0,
               format,
               _size.x, _size.y,
               0,
               format,
               GL_UNSIGNED_BYTE,
               NULL);
  
  // Set up parameters for this particular texture
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  
  
  glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, fboTex, 0);
  
//  glBindRenderbuffer(GL_RENDERBUFFER, depthBuffer);
//  glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24_OES, fbo_width, fbo_height);
//  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthBuffer);
  
  GLenum status;
  status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
  ASSERT(status == GL_FRAMEBUFFER_COMPLETE,@"frame buffer status is %d",status);
}

- (void)closeRender {
  // Restore previous active frame buffer
  glBindFramebuffer(GL_FRAMEBUFFER, _savedFBOIdentifier);
}

@end

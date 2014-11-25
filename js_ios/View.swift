import Foundation
import GLKit

public class View : NSObject {
  
  public var bounds: CGRect {
    didSet {
      puts("set bounds to \(d(self.bounds))")
    }
  }

  private(set) var opaque:Bool = true
  private(set) var cacheable:Bool = true
  private var cachedTexture:Texture? = nil
  public var children: Array<View> = []
  
  public init(_ size:CGPoint, _ opaque:Bool = true, _ cacheable:Bool = true) {
    self.bounds = CGRect(0,0,size.x,size.y)
    self.opaque = opaque
    self.cacheable = cacheable
    super.init()
  }
  
  public override var description : String {
    return "View(opaque:\(d(self.opaque)) cached:\(d(cacheable)) bounds \(bounds) cachedTex \(cachedTexture))"
  }

  public func add(childView:View) {
  	children.append(childView)
  }
  
  public func paint() {
//    puts("\n\npaint \(self)")
    if (self.cacheable) {
      paintCacheable()
      paintFromCachedTexture()
    } else {
    }
  }
  
  private func paintCacheable() {
    if (cachedTexture != nil) {
      return
    }
    createTextureCache()
    paintIntoCache()
  }
  
  private func createTextureCache() {
    var texSize = self.bounds.ptSize
    texSize = GLTools.smallestPowerOfTwo(texSize)
    let texId = GLTools.createTexture(texSize,withAlphaChannel:!self.opaque)
    self.cachedTexture = Texture(textureId:texId,size:texSize,hasAlpha:!self.opaque)
  }
  
  private func paintIntoCache() {
    GLTools.verifyFrameBufferStatus()
    
    GLTools.pushNewFrameBuffer()
    
    // See:  https://github.com/glman74/simpleFBO/blob/master/simpleFBO/ViewController.m
    
    glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), self.cachedTexture!.textureId, 0)
    GLTools.verifyNoError()
    GLTools.verifyFrameBufferStatus()
    
    if (self.opaque) {
      glClearColor(0.0,0.0,0.5, 1.0)
    } else {
      glClearColor(0.2,0.4,0.8,0.5)
    }
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    GLTools.verifyNoError()
    
    if (cond(true)) {
      let tex = Texture(pngName:"blob")
      let sprite = GLSprite(texture:tex,window:self.bounds,program:nil)
      sprite.render(CGPoint(0,0))
    }
    
    GLTools.popFrameBuffer()
  }
  
  private func paintFromCachedTexture() {
    let sprite = GLSprite(texture:self.cachedTexture,window:self.bounds,program:nil)
    sprite.render(CGPoint.zero)
  }
  
}
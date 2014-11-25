import Foundation
import GLKit

public class View : NSObject {
  
  public var bounds: CGRect
  private(set) var opaque:Bool = true
  private(set) var cacheable:Bool = true
  public var children: Array<View> = []
  
  // Texture holding cached rendered view
  private var cachedTexture:Texture? = nil
  // True iff the cached view contents (if they exist) are valid, vs need to be redrawn
  private var cachedTextureValid = false
  
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
  
  // Mark any existing cached view content as invalid, so content is redrawn when view is next plotted
  //
  public func invalidate() {
    cachedTextureValid = false
  }
  
  public func plot() {
    if (self.cacheable) {
      constructCachedContent()
      plotCachedTexture()
    } else {
    }
  }
  
  private func constructCachedContent() {
    if (cachedTextureValid && cachedTexture != nil) {
      return
    }
    
    // Dispose of old texture cache if it exists and its size differs from required
    if (cachedTexture != nil) {
      if (calcRequiredTextureSize() != cachedTexture!.bounds.ptSize) {
      	disposeTextureCache()
      }
    }
    if (cachedTexture == nil) {
    	createTextureCache()
    }
    plotIntoCache()
    cachedTextureValid = true
  }
  
  private func calcRequiredTextureSize() -> CGPoint {
    var texSize = self.bounds.ptSize
    texSize = GLTools.smallestPowerOfTwo(texSize)
    return texSize
  }
  
  private func disposeTextureCache() {
    cachedTexture = nil
  }
  
  private func createTextureCache() {
    let texSize = calcRequiredTextureSize()
    let texId = GLTools.createTexture(texSize,withAlphaChannel:!self.opaque)
    cachedTexture = Texture(textureId:texId,size:texSize,hasAlpha:!self.opaque)
  }
  
  private func plotIntoCache() {
    GLTools.pushNewFrameBuffer()
    
    glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), self.cachedTexture!.textureId, 0)
    GLTools.verifyNoError()
    GLTools.verifyFrameBufferStatus()
    
    unimp("call user function to render view content")
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
  
  private func plotCachedTexture() {
    let sprite = GLSprite(texture:self.cachedTexture,window:self.bounds,program:nil)
    sprite.render(CGPoint.zero)
  }
  
}


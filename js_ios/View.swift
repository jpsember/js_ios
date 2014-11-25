import Foundation
import GLKit


public class View : NSObject {
  
  public typealias PlotHandler = (View) -> Void
  
  public var bounds: CGRect
  
  // The handler for plotting view content; default clears it and that's all
  //
  public var plotHandler : PlotHandler = View.defaultPlotHandlerFunction
  
  // If opaque, completely obscures any view behind it
  private(set) var opaque = true
  
  // If cacheable, view is rendered to an offscreen buffer and plotted from there
  private(set) var cacheable = true
  
  public var children: Array<View> = []
  
  // Texture holding cached rendered view
  private var cachedTexture:Texture? = nil
  // True iff the cached view contents (if they exist) are valid, vs need to be redrawn
  private var cachedTextureValid = false
  
  // If true, texture constructed for caching view's content will have dimensions padded 
  // if necessary to be a power of 2.  According to ES 2.0 specificiation
  // (see http://stackoverflow.com/questions/11069441/non-power-of-two-textures-in-ios ),
  // non-power-of-two (npot) textures are supported as long as their wrap parameters are
  // set to CLAMP; not sure about the min/mag settings, or whether mipmapping supported.
  private var ENFORCE_TEX_POWER_2 = cond(false)
  
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
        puts("disposing of old texture cache, size \(cachedTexture!.bounds.ptSize) differs from \(calcRequiredTextureSize())")
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
    if (ENFORCE_TEX_POWER_2) {
    	texSize = GLTools.smallestPowerOfTwo(texSize)
    }
    return texSize
  }
  
  private func disposeTextureCache() {
    cachedTexture = nil
  }
  
  private func createTextureCache() {
    let texSize = calcRequiredTextureSize()
    let texId = GLTools.createTexture(texSize,withAlphaChannel:!self.opaque,withRepeat:ENFORCE_TEX_POWER_2, context:"cache for View")
    cachedTexture = Texture(textureId:texId,size:texSize,hasAlpha:!self.opaque)
  }
  
  private func plotIntoCache() {
    GLTools.pushNewFrameBuffer()
    
    glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), self.cachedTexture!.textureId, 0)
    GLTools.verifyNoError()
    GLTools.verifyFrameBufferStatus()
    
    plotHandler(self)
    
    GLTools.popFrameBuffer()
  }
  
  private func plotCachedTexture() {
    let sprite = GLSprite(texture:self.cachedTexture,window:self.bounds,program:nil)
    sprite.render(bounds.origin)
  }
  
  public func defaultPlotHandler() {
    if (opaque) {
      glClearColor(0,0,0,1)
    } else {
      glClearColor(0,0,0,0)
    }
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
  }
  
  private class func defaultPlotHandlerFunction(view : View) {
    view.defaultPlotHandler()
  }

}


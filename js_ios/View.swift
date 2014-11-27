import Foundation
import GLKit

public class View : NSObject {
  
  public typealias PlotHandler = (View) -> Void
  
  // The bounds of the view, relative to the parent view's origin
  public var bounds: CGRect
  
  public var position : CGPoint {
    get {
      return bounds.origin
    }
    set {
      bounds = CGRect(origin:newValue, size:bounds.size)
    }
  }
  
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
  
  public init(_ size:CGPoint, opaque:Bool = true, cacheable:Bool = true) {
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
  
  // Mark view as invalid, so it will be redrawn (perhaps after a short delay).  If view is cached,
  // its cached texture is considered invalid, and will be redrawn
	//
  public func invalidate() {
    cachedTextureValid = false
  }
  
  // Plot view. If cacheable, renders to texture (if cached version doesn't exist or is invalid), 
  // then plots from texture to OpenGL view.  If not cacheable, renders directly to OpenGL view
	//
  public func plot(containerSize:CGPoint, _ parentOrigin:CGPoint) {
    if (self.cacheable) {
      unimp("set up transformations for cached content")
      constructCachedContent()
      plotCachedTexture()
    } else {
      let ourOrigin = CGPoint.sum(parentOrigin,bounds.origin)
      let transform = calcOpenGLTransform(containerSize,ourOrigin)
      Renderer.sharedInstance().setTransform(transform)
      plotHandler(self)
    }
  }
  
  /**
  * Construct matrix to transform from view manager bounds to OpenGL's
  * normalized device coordinates (-1,-1 ... 1,1)
  */
  private func calcOpenGLTransform(containerSize:CGPoint, _ ourOrigin:CGPoint) -> CGAffineTransform {
    let w = containerSize.x
    let h = containerSize.y
    let sx = 2 / w
    let sy = 2 / h
    
    let scale = CGAffineTransformMakeScale(sx, sy)
    let translate = CGAffineTransformMakeTranslation(-w/2 + ourOrigin.x,-h/2 + ourOrigin.y)
    let result = CGAffineTransformConcat(translate,scale)
    
    return result
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
    cachedTexture = Texture(size:texSize,hasAlpha:!self.opaque,withRepeat:ENFORCE_TEX_POWER_2,context:"cache for View")
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


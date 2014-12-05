import Foundation
import GLKit

public class View : NSObject {
  
  public typealias PlotHandler = (View) -> Void
  public typealias TouchHandler = (TouchEvent,View) -> Bool
  
  // The bounds of the view, relative to the parent view's origin
  public var bounds: CGRect
  
  public var position : CGPoint {
    get {
      return bounds.origin
    }
    set {
      bounds.origin = newValue
    }
  }
  public var size : CGPoint {
    get {
      return bounds.ptSize
    }
    set {
      bounds.size = CGSize(width:newValue.x,height:newValue.y)
    }
  }
	
  // This is the position of the view relative to the root view.
  // It is updated by the view manager each time the view hierarchy is plotted
  public var absolutePosition = CGPoint.zero
  
  // The handler for plotting view content; default does nothing
  //
  public var plotHandler : PlotHandler!
  
  // If opaque, completely obscures any view behind it
  public var opaque = true
  
  // If cacheable, view is rendered to an offscreen buffer and plotted from there
  public var cacheable = false
  
  public var children: Array<View> = []
  
  // The optional handler for touch events.  The event location is relative to this view's coordinate system.
  // If it is a Down event, the handler should return true if the touch sequence (Down/Drag/Up) is to be handled
  // by this view.  The return code is ignored for other event types.
  public var touchHandler: TouchHandler?
  
  // Texture holding cached rendered view
  private var cachedTexture:Texture!
  // True iff the rendered view contents (if they exist) are valid, vs need to be redrawn
	private(set) var renderedViewValid = false
  
  // If true, texture constructed for caching view's content will have dimensions padded 
  // if necessary to be a power of 2.  According to ES 2.0 specificiation
  // (see http://stackoverflow.com/questions/11069441/non-power-of-two-textures-in-ios ),
  // non-power-of-two (npot) textures are supported as long as their wrap parameters are
  // set to CLAMP; not sure about the min/mag settings, or whether mipmapping supported.
  private var ENFORCE_TEX_POWER_2 = cond(false)
  
  public override init() {
    self.bounds = CGRect.undefined
    super.init()
    self.plotHandler = defaultPlotHandler
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
   	renderedViewValid = false
  }
  
  public func preparePlot() {
    let renderer = Renderer.sharedInstance()
    let transform = calcOpenGLTransform(renderer.defaultViewportSize,absolutePosition,false)
    renderer.resetOpenGLState()
    renderer.transform = transform
  }
  
  // Plot view. If cacheable, renders to texture (if cached version doesn't exist or is invalid),
  // then plots from texture to OpenGL view.  If not cacheable, renders directly to OpenGL view
	//
  public func plot() {
    preparePlot()
    let renderer = Renderer.sharedInstance()
    if (self.cacheable) {
      let savedTransform = renderer.transform
      if (constructCachedContent()) {
        renderer.resetOpenGLState()
        renderer.transform = savedTransform
      }
      plotCachedTexture()
    } else {
      // Clip rendering to this view's bounds
      glEnable(GLenum(GL_SCISSOR_TEST))
      glScissor(GLint(absolutePosition.x),GLint(absolutePosition.y),GLint(bounds.size.width),GLint(bounds.size.height));
      plotHandler(self)
      glDisable(GLenum(GL_SCISSOR_TEST))
    }
    renderedViewValid = true
  }
  
  /**
  * Construct matrix to transform from view manager bounds to OpenGL's
  * normalized device coordinates (-1,-1 ... 1,1)
  */
  private func calcOpenGLTransform(containerSize:CGPoint, _ ourOrigin:CGPoint, _ offscreen:Bool) -> CGAffineTransform {
    let w = containerSize.x
    let h = containerSize.y
    let sx = 2 / w
    let sy = 2 / h
    
    let scale = CGAffineTransformMakeScale(sx, sy)
    let translate = CGAffineTransformMakeTranslation(-w/2 + ourOrigin.x,-h/2 + ourOrigin.y)
    let result = CGAffineTransformConcat(translate,scale)
    
    return result
  }
  
  // Construct cached texture (if it doesn't exist, or is invalid), and redraw if necessary
  // Returns true if rendering may have occurred (and state modified)
  //
  private func constructCachedContent() -> Bool {
    if (renderedViewValid && cachedTexture != nil) {
      return false
    }
    
    // Dispose of old texture cache if it exists and its size differs from required
    if (cachedTexture != nil) {
      if (calcRequiredTextureSize() != cachedTexture.bounds.ptSize) {
      	disposeTextureCache()
      }
    }
    if (cachedTexture == nil) {
    	createTextureCache()
    }
    plotIntoCache()
    return true
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
    
    let renderer = Renderer.sharedInstance()
		GLTools.pushNewFrameBuffer()
    
    glViewport(0,0,GLsizei(cachedTexture.width),GLsizei(cachedTexture.height))
    
    glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), cachedTexture.textureId, 0)
    
    // Clear the framebuffer
    if (opaque) {
      glClearColor(0,0,0,1)
    } else {
      glClearColor(0,0,0,0)
    }
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

    GLTools.verifyNoError()
    GLTools.verifyFrameBufferStatus()
    
    let texSize = cachedTexture.size
    renderer.transform = calcOpenGLTransform(texSize,CGPoint.zero,true)
    plotHandler(self)
    
    GLTools.popFrameBuffer()
    
    // Restore viewport to root view's bounds
    let size = renderer.defaultViewportSize
		glViewport(0,0,GLsizei(size.x),GLsizei(size.y))
    
  }
  
  private func plotCachedTexture() {
    let texWindow = CGRect(0,0,self.bounds.width,self.bounds.height)
		let renderer = Renderer.sharedInstance()
    let sprite = GLSprite(texture:self.cachedTexture,window:texWindow,program:nil)
    sprite.render(CGPoint.zero)
  }
  
  public func defaultPlotHandler(view : View) {
  }

}


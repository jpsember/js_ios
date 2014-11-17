import GLKit

@UIApplicationMain // Allows us to omit a main.m file
public class GLAppDelegate : AppDelegate, GLKViewDelegate {
  
  private var timer : NSTimer?
  private var view : UIView?
  private var texture : Texture?
  private var spriteProgram : GLSpriteProgram?
  private var renderer : Renderer?
  private var spriteContext : GLSpriteContext?
  
  private var angle = 0.0
  private let PI = 3.141592
  private let fps = 30.0
  private var preparedViewSize  = CGSizeMake(0,0)
  
  private func freeTextures() {
 		texture = nil
  }
  
  private func loadTextures() {
    if (texture != nil) {
      return
    }
    
    let t = Texture()
    var pngName = "AlphaBall"
   	pngName = "sample"
    
    t.loadBitmap(pngName)
    texture = t

    let tintMode = false
    if (tintMode) {
      spriteContext = GLSpriteContext(transformName:Renderer.transformNameDeviceToNDC(), tintMode:true )
      spriteContext!.setTintColor(UIColor.redColor())
    } else {
      spriteContext = GLSpriteContext(transformName:Renderer.transformNameDeviceToNDC(), tintMode:false )
    }
    
    let tw = CGRectMake(0,0,CGFloat(texture!.width),CGFloat(texture!.height))
    spriteProgram = GLSpriteProgram(context: spriteContext, texture: texture, window: tw)
  }
  
  private func prepareGraphics(viewSize : CGSize) {
    // If previous size undefined, or different than new, invalidate old graphic elements
    if (preparedViewSize == viewSize) {
      return
    }
    preparedViewSize = viewSize
    puts("preparing renderer for view size \(preparedViewSize)")
    
    if (renderer == nil) {
      renderer = Renderer()
    }
    renderer!.surfaceCreated(Point(preparedViewSize))
		
    if (spriteProgram != nil) {
      return
    }
    
    puts("preparing shaders, textures, sprites")
    
    loadTextures()
  }
  
  public func glkView(view : GLKView!, drawInRect : CGRect) {
    
    GLTools.verifyNoError()
    
    // A nice green color
    glClearColor(0.0, 0.5, 0.1, 1.0)
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    GLTools.verifyNoError()
    
    prepareGraphics(view!.bounds.size)
    
    angle += (PI / 180.0) * (60 / fps)
    
    let x = CGFloat(300.0 + cos(angle) * 250.0)
    let y = CGFloat(300.0 + sin(angle) * 250.0)
    
    spriteProgram!.setPosition(x,y:y)
    spriteProgram!.render()
    GLTools.verifyNoError()
  }
  
  override public func buildView() -> UIView {
    let view = GLView(frame:self.window!.bounds)
    view.delegate = self
    self.view = view
    
    // Set up a timer to redraw the screen several times a second
    // Define the timer object
    timer = NSTimer.scheduledTimerWithTimeInterval(1.0/fps, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
    return view
  }
  
  public func updateTimer() {
    self.view?.setNeedsDisplay()
  }

}

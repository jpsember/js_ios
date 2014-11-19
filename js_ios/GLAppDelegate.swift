import GLKit

@UIApplicationMain // Allows us to omit a main.m file
public class GLAppDelegate : AppDelegate, GLKViewDelegate {
  
  private var timer : NSTimer?
  private var view : UIView?
  private var texture : Texture?
  private var texture2 : Texture?
  private var sprite : GLSprite?
  private var renderer : Renderer?
  private var spriteProgram : GLSpriteProgram?
  private var spriteProgram2 : GLSpriteProgram?
  private var sprite2 : GLSprite?
  
  private var angle = 0.0
  private let PI = 3.141592
  private let fps = 30.0
  private var preparedViewSize  = CGSizeMake(0,0)
  
  private func loadTextures() {
    if (texture != nil) {
      return
    }
    
    spriteProgram = GLSpriteProgram(transformName:Renderer.transformNameDeviceToNDC(), tintMode:false )
    texture = Texture("sample")
    sprite = GLSprite(program:spriteProgram, texture:texture)
    
    spriteProgram2 = GLSpriteProgram(transformName:Renderer.transformNameDeviceToNDC(), tintMode:true )
    spriteProgram2!.setTintColor(UIColor.redColor())
    texture2 = Texture("AlphaBall")
    sprite2 = GLSprite(program: spriteProgram2, texture:texture2)
  }
  
  private func prepareGraphics(viewSize : CGSize) {
    // If previous size undefined, or different than new, invalidate old graphic elements
    if (preparedViewSize == viewSize) {
      return
    }
    preparedViewSize = viewSize
    if (renderer == nil) {
      renderer = Renderer()
    }
    renderer!.surfaceCreated(CGPoint(preparedViewSize))
		
    if (sprite != nil) {
      return
    }
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
    
    sprite!.render(CGPoint(x,y))
    sprite2!.render(view!.bounds.midPoint);
    
    if (true) {
      let t = (angle % (2*PI))/(2*PI)
      let color = UIColor(red:CGFloat(t), green:CGFloat(0.25+t/2), blue: CGFloat(0.75-t/2), alpha: CGFloat(t))
      spriteProgram2!.setTintColor(color)
    }
    
    GLTools.verifyNoError()
    
    if (angle > PI*6) {
      exitApp()
    }
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

import GLKit

@UIApplicationMain // Allows us to omit a main.m file
public class GLAppDelegate : AppDelegate, GLKViewDelegate {
  
  private var timer : NSTimer?
  private var view : UIView?
  private var texture : Texture?
  private var texture2 : Texture?
  private var spriteProgram : GLSpriteProgram?
  private var renderer : Renderer?
  private var spriteContext : GLSpriteContext?
  private var spriteContext2 : GLSpriteContext?
  private var spriteProgram2 : GLSpriteProgram?
  
  private var angle = 0.0
  private let PI = 3.141592
  private let fps = 30.0
  private var preparedViewSize  = CGSizeMake(0,0)
  
  private func loadTextures() {
    if (texture != nil) {
      return
    }
    
    spriteContext = GLSpriteContext(transformName:Renderer.transformNameDeviceToNDC(), tintMode:false )
    texture = Texture("sample")
    spriteProgram = GLSpriteProgram(context:spriteContext, texture:texture)
    
    spriteContext2 = GLSpriteContext(transformName:Renderer.transformNameDeviceToNDC(), tintMode:true )
    spriteContext2!.setTintColor(UIColor.redColor())
    texture2 = Texture("AlphaBall")
    spriteProgram2 = GLSpriteProgram(context: spriteContext2, texture:texture2)
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
		
    if (spriteProgram != nil) {
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
    
    spriteProgram!.setPosition(x,y:y)
    spriteProgram!.render()
    
    spriteProgram2!.setPosition(view!.bounds.size.width / 2, y:view!.bounds.size.height/2);
    spriteProgram2!.render();
    
    if (true) {
      let t = (angle % (2*PI))/(2*PI)
      let color = UIColor(red:CGFloat(t), green:CGFloat(0.25+t/2), blue: CGFloat(0.75-t/2), alpha: CGFloat(t))
      spriteContext2!.setTintColor(color)
    }
    
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

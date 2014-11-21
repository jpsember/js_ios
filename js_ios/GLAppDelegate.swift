import GLKit

@UIApplicationMain // Allows us to omit a main.m file
public class GLAppDelegate : AppDelegate, GLKViewDelegate {
  
  private var timer : NSTimer?
  private var view : UIView?
  private var bgndTexture : Texture?
  private var ballTexture : Texture?
  private var bgndSprite : GLSprite?
  private var renderer : Renderer?
  private var ballSprite : GLSprite?
  private var blobSprite : GLSprite?
  
  private var angle : CGFloat = 0.0
  private let fps : CGFloat = 30.0
  private var preparedViewSize  = CGSizeMake(0,0)
  
  private func loadTextures() {
    if (bgndTexture != nil) {
      return
    }
    
    bgndTexture = Texture("tile")
    bgndSprite = GLSprite(texture:bgndTexture, window:bgndTexture!.bounds, program:nil)
    
    ballTexture = Texture("AlphaBall")
    ballSprite = GLSprite(texture:ballTexture, window:ballTexture!.bounds, program:GLTintedSpriteProgram.getProgram())
  
    let blobTexture = Texture("blob")
    blobSprite = GLSprite(texture:blobTexture, window:blobTexture.bounds, program:nil)

    bgndSprite = GLSprite(texture:bgndTexture, window:CGRect(-120,-120,1000,1000), program:nil)
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
		
    if (bgndSprite != nil) {
      return
    }
    loadTextures()
  }
  
  public func glkView(view : GLKView!, drawInRect : CGRect) {
    
    let EXAMPLE_TINT = true || alwaysFalse()
    let EXAMPLE_TILE = true || alwaysFalse()
    
    GLTools.verifyNoError()
    
    // A nice green color
    glClearColor(0.0, 0.5, 0.1, 1.0)
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    GLTools.verifyNoError()
    GLTools.initializeOpenGLState()
    
    prepareGraphics(view!.bounds.size)
    
    angle += degrees(60 / fps)
    if (EXAMPLE_TILE) {
   	  bgndSprite!.render(pointOnCircle(CGPoint.zero, 0.5, angle*5))
    }
    
    if (EXAMPLE_TINT) { // Limit the scope of the variables within; swift is missing the feature '{ ... }' of Obj-C, Java, ...
      let t = (angle % (2*pi))/(2*pi)
      let color = UIColor(red:CGFloat(t), green:CGFloat(0.25+t/2), blue: CGFloat(0.75-t/2), alpha: CGFloat(t))
      GLTintedSpriteProgram.getProgram().setTintColor(color)
      ballSprite!.render(view!.bounds.midPoint);
    }
    blobSprite!.render(pointOnCircle(CGPoint(220,400),317,angle * 0.5))
    blobSprite!.render(pointOnCircle(CGPoint(260,320),117,angle * 1.2))
    
    GLTools.verifyNoError()
    
    if (angle > pi*6) {
      exitApp()
    }
  }
  
  override public func buildView() -> UIView {
    let view = GLView(frame:self.window!.bounds)
    view.delegate = self
    self.view = view
    
    // Set up a timer to redraw the screen several times a second
    // Define the timer object
    timer = NSTimer.scheduledTimerWithTimeInterval(Double(1/fps), target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
    return view
  }
  
  public func updateTimer() {
    self.view?.setNeedsDisplay()
  }

}

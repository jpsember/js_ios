import GLKit


@UIApplicationMain // Allows us to omit a main.m file
public class GLAppDelegate : AppDelegate, GLKViewDelegate {
  
  private var timer : NSTimer?
  private var view : UIView?
  private var texture : Texture?
  private var texture2 : Texture?
  private var sprite : GLSprite?
  private var renderer : Renderer?
  private var sprite2 : GLSprite?
  private var sprite3 : GLSprite?
  
  private var angle : CGFloat = 0.0
  private let fps : CGFloat = 30.0
  private var preparedViewSize  = CGSizeMake(0,0)
  
  private func loadTextures() {
    if (texture != nil) {
      return
    }
    
    texture = Texture("tile")
    sprite = GLSprite(texture:texture, window:texture!.bounds, program:nil)
    
    texture2 = Texture("AlphaBall")
    sprite2 = GLSprite(texture:texture2, window:texture2!.bounds, program:GLTintedSpriteProgram.getProgram())
  
    let texture3 = Texture("blob")
    sprite3 = GLSprite(texture:texture3, window:texture3.bounds, program:nil)

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
    
    angle += degrees(60 / fps)
    
    sprite!.render(pointOnCircle(CGPoint(300,300),250,angle))
    
    if (true) { // Limit the scope of the variables within; swift is missing the feature '{ ... }' of Obj-C, Java, ...
      let t = (angle % (2*pi))/(2*pi)
      let color = UIColor(red:CGFloat(t), green:CGFloat(0.25+t/2), blue: CGFloat(0.75-t/2), alpha: CGFloat(t))
      GLTintedSpriteProgram.getProgram().setTintColor(color)
    }
    sprite2!.render(view!.bounds.midPoint);
    sprite3!.render(pointOnCircle(CGPoint(220,400),317,angle * 0.5))
    
    // Plot overlapping alpha & non-alpha sprites in a circle to test the blending
    for i:Int in 0..<10 {
      let i2 = CGFloat(i)
      let loc = CGPoint(400.0+i2*2,200.0+i2*24)
      var s : GLSprite
      switch (i % 2) {
      case 0: s = sprite!
      default: s = sprite3!
      }
      
      let orig = CGPoint(300,350)
      s.render(pointOnCircle( orig, CGFloat(60.2), degrees(CGFloat(i*36)) ))
    }
    
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

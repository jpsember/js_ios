import GLKit

@UIApplicationMain // Allows us to omit a main.m file
public class GLAppDelegate : AppDelegate {
  
  override public func buildView() -> UIView {
    viewManager = ViewManager(bounds:self.window!.bounds)
    
    // Construct a root View
    let view = View(viewManager.baseUIView.bounds.ptSize, opaque:true, cacheable:false)
    viewManager.rootView = view
    view.plotHandler = { (view) in
      self.updateOurView()
    }
    
    // Start a timer to update the root view several times a second
    NSTimer.scheduledTimerWithTimeInterval(Double(1/fps), target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
    
    return viewManager.baseUIView
  }
  
  // Called by the NSTimer; ideally would be private
  //
  public func updateTimer() {
    updateLogic()
    unimp("have a View method that requests refresh, which ultimately calls setNeedsDisplay")
    viewManager.baseUIView.setNeedsDisplay()
  }
  
  private var ourView : View {
    get {
      return viewManager.rootView
    }
  }
  
  private var viewManager : ViewManager!
  
  // ------------------------------------
  // Logic-related : state and behaviour
  //
  private let fps : CGFloat = 8.0
  private var angle : CGFloat = 0.0
  private var frame : Int = 0
  
  private func updateLogic() {
    frame += 1
    angle += degrees(60 / fps)
    if (angle > pi*6) {
      exitApp()
    }
    
    // Invalidate our view, so it's redrawn
    ourView.invalidate()
  }
  
  // -------------------------------------------
  // Draw-related : renders current logic state
  
  private func updateOurView() {
    prepareGraphics()
		glClearColor(0.0,0,0.7,1.0)
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    blobSprite.render(pointOnCircle(CGPoint(220,400),317,angle * 0.5))
    blobSprite.render(pointOnCircle(CGPoint(260,320),117,angle * 1.2))
  }
  
  // Prepare the graphics, if they haven't already been
  //
  private func prepareGraphics() {
    if (blobSprite != nil) {
      return
    }
    let blobTexture = getTexture("blob")
    blobSprite = GLSprite(texture:blobTexture, window:blobTexture.bounds, program:nil)
  }
  
  private var textureMap = Dictionary<String,Texture>()
  private var blobSprite : GLSprite!
  
  private func getTexture(name : String) -> Texture {
    var tex = textureMap[name]
    if tex == nil {
      tex = Texture(pngName:name)
      textureMap[name] = tex
    }
    return tex!
  }

}

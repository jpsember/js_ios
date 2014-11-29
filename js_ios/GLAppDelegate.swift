import GLKit

@UIApplicationMain // Allows us to omit a main.m file
public class GLAppDelegate : AppDelegate {
  
  override public func buildView() -> UIView {
    viewManager = ViewManager(bounds:self.window!.bounds)
    
    // Construct a root View
    let view = View(viewManager.baseUIView.bounds.ptSize, opaque:true, cacheable:false)
    viewManager.rootView = view
    view.plotHandler = { (view) in self.updateOurView() }
    
    var subviewY = 120
    var subview : View
    
    // Construct a child view that is translucent and (for the moment) non-cacheable;
    // it will have a static sprite as a background, and a smaller sprite moving in a small circle
    subview = View(CGPoint(256,256), opaque:false, cacheable:false)
    subview.position = CGPoint(150,subviewY)
    subviewY += 256 + 10
    view.add(subview)
    subview.plotHandler = { (view) in self.updateSubview1(view) }
    
    // Construct a second child view, like the first but cacheable; this one is actually opaque
    subview = View(CGPoint(256,256), opaque:true, cacheable:true)
    subview.position = CGPoint(150,subviewY)
    view.add(subview)
    subview.plotHandler = { (view) in self.updateSubview2(view) }
    cachedView = subview
    
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
  private var cachedView : View!
  
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
    
    // Invalidate our root view, so it's redrawn
    ourView.invalidate()
    
    // Invalidate the second child view (which is cached) every once in a while
    if (frame % 8 == 0) {
    	cachedView.invalidate()
    }
  }
  
  // -------------------------------------------
  // Draw-related : renders current logic state
  
  private func updateOurView() {
    prepareGraphics()
   
    bgndSprite.render(CGPoint.zero)
    
    blobSprite.render(pointOnCircle(CGPoint(220,400),317,angle * 0.5))
    blobSprite.render(pointOnCircle(CGPoint(260,320),117,angle * 1.2))
  }
  
  private func updateSubview1(subview : View) {
    prepareGraphics()
    ballSprite.render(CGPoint.zero)
    blobSprite.render(pointOnCircle(CGPoint(110,110),16,angle*3.2))
    
    var p = GLTintedSpriteProgram.getProgram()
    p.tintColor = UIColor.greenColor()
    tintedSprite.render(CGPoint(20,20))
    
    p.tintColor = UIColor.redColor()
    tintedSprite.render(CGPoint(60,50))
  }

  private func updateSubview2(subview : View) {
    prepareGraphics()
		superSprite.render(CGPoint.zero)
		blobSprite.render(pointOnCircle(CGPoint(110,110),16,angle*3.2))
  }
  
  // Prepare the graphics, if they haven't already been
  //
  private func prepareGraphics() {
    if (blobSprite != nil) {
      return
    }
    var texture = getTexture("blob")
    blobSprite = GLSprite(texture:texture, window:texture.bounds, program:nil)
    
    texture = getTexture("tile")
    texture.setRepeat(true)
    bgndSprite = GLSprite(texture:texture, window:CGRect(0,0,2000,2000), program:nil)
    
    texture = getTexture("AlphaBall")
		ballSprite = GLSprite(texture:texture, window:texture.bounds, program:nil)
    
    texture = getTexture("super")
    superSprite = GLSprite(texture:texture, window:texture.bounds, program:nil)
    
    texture = getTexture("tinted")
    tintedSprite = GLSprite(texture:texture, window:texture.bounds, program:GLTintedSpriteProgram.getProgram())
  }
  
  private var textureMap = Dictionary<String,Texture>()
  private var blobSprite : GLSprite!
  private var bgndSprite : GLSprite!
  private var ballSprite : GLSprite!
  private var superSprite : GLSprite!
  private var tintedSprite : GLSprite!
  
  private func getTexture(name : String) -> Texture {
    var tex = textureMap[name]
    if tex == nil {
			tex = Texture(pngName:name)
      textureMap[name] = tex
    }
    return tex!
  }

}

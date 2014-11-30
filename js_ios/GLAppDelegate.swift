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
    subviewY += 256 + 10
    subview.plotHandler = { (view) in self.updateSubview2(view) }
    cachedView = subview
    
    // Construct a third child view, that will contain other views within it
    subview = View(CGPoint(256,256), opaque:false, cacheable:true)
    subview.position = CGPoint(150,subviewY)
    view.add(subview)
    subview.plotHandler = { (view) in
      self.superSprite.render(CGPoint.zero) }
    
    var subview2 = View(CGPoint(64,64), opaque:false, cacheable:true)
    subview2.position = CGPoint(10,10)
    subview2.plotHandler = {(view) in
      self.bgndSprite.render(CGPoint.zero)
      self.blobSprite.render(CGPoint.zero)
    }
    movingView = subview2
    
    subview.add(subview2)
    
    startTicker()
    
    return viewManager.baseUIView
  }
  
  private func startTicker() {
    let ticker = Ticker.sharedInstance()
    ticker.ticksPerSecond = fps
    ticker.logicCallback = updateLogic
    ticker.exitTime = CGFloat(15)
    ticker.viewManager = viewManager
    ticker.start()
  }
  
  private var ourView : View {
    get {
      return viewManager.rootView
    }
  }
  
  private var viewManager : ViewManager!
  private var cachedView : View!
  private var movingView : View!
  
  // ------------------------------------
  // Logic-related : state and behaviour
  //
  private let fps : CGFloat = 8.0
  private var angle : CGFloat = 0.0
  private var frame : Int = 0
  
  private func updateLogic() {
    frame += 1
    angle += degrees(60 / fps)
    
    if (frame % 4 == 0) {
    	movingView!.bounds.origin = pointOnCircle(CGPoint(64,64),32,angle * 0.5)
      movingView.invalidate()
    }
    
    // Verify that if we don't invalidate anything, no updating occurs
    if (frame >= 20 && frame <= 45) {
      return
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
    blobSprite.render(pointOnCircle(CGPoint(110,110),16,angle*0.4))
    
    var p = GLTintedSpriteProgram.getProgram()
    p.tintColor = UIColor.greenColor()
    tintedSprite.render(CGPoint(20,20))
    p.tintColor = UIColor.redColor()
    tintedSprite.render(CGPoint(60,50))
    p.tintColor = UIColor.blueColor()
    tintedSprite.render(CGPoint(220,80))
  }

  private func updateSubview2(subview : View) {
    prepareGraphics()
		superSprite.render(CGPoint.zero)
		blobSprite.render(pointOnCircle(CGPoint(110,110),16,angle*0.4))
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

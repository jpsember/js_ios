import GLKit

@UIApplicationMain // Allows us to omit a main.m file
public class GLAppDelegate : AppDelegate {
  
  private let WITH_PATH = cond(false)
  private let WITH_ICONPANEL = cond(true)
  private let ICON_PANEL_TOTAL_ROWS = 3

  override public func buildView() -> UIView {
    let viewManager = ViewManager.construct(window!.bounds)
    
    // Construct a root View
    let view = View()
    view.bounds.size = viewManager.baseUIView.bounds.size
    viewManager.rootView = view
    
    if (!WITH_ICONPANEL) {
      view.replacePlotHandlerWith(mainViewPlotHandler)
      view.touchHandler = mainViewTouchHandler
      
      var subviewY = 20
      var subview : View
      
      // Construct a child view that is translucent and (for the moment) non-cacheable;
      // it will have a static sprite as a background, and a smaller sprite moving in a small circle
      subview = View()
      subview.opaque = false
      subview.size = CGPoint(256,256)
      subview.position = CGPoint(420,subviewY)
      subviewY += 256 + 10
      view.add(subview)
      subview.replacePlotHandlerWith(updateSubview1)
      
      // Construct a second child view, like the first but cacheable; this one is actually opaque
      subview = View()
      subview.cacheable = true
      subview.size = CGPoint(256,256)
      subview.position = CGPoint(420,subviewY)
      view.add(subview)
      subviewY += 256 + 10
      subview.replacePlotHandlerWith(updateSubview2)
      
      // Construct a third child view, that will contain other views within it
      subview = View()
      subview.cacheable = true
      subview.opaque = false
      subview.size = CGPoint(256,256)
      subview.position = CGPoint(420,subviewY)
      view.add(subview)
      subview.replacePlotHandlerWith(updateSubview2)
      subview.touchHandler = subviewTouchHandler
      
      var subview2 = View()
      subview2.opaque = false
      subview2.cacheable = true
      subview2.size = CGPoint(64,64)
      subview2.position = CGPoint(430,30)
      subview2.replacePlotHandlerWith {(view) in
        self.bgndSprite.render(CGPoint.zero)
        self.blobSprite.render(CGPoint.zero)
      }
      dragView = subview2
      subview.add(dragView)
    
    } else {
      
      for var pass = 0; pass < 2; pass++ {
        var p = IconPanel()
        p.rowHeight = 36
        let origPlotHandler = p.replacePlotHandlerWith(iconPlotHandler)
        if pass == 0 {
          iconPanel = p
          p.size = CGPoint(280,p.rowHeight*CGFloat(ICON_PANEL_TOTAL_ROWS))
          p.position = CGPoint(10,250)
          originalIconPanelPlotHandler = origPlotHandler
        } else {
          p.size = CGPoint(140,p.rowHeight * CGFloat(1))
          p.position = CGPoint(10,400)
        }
        p.textureProvider = iconViewTextureProvider
        view.add(p)
        viewManager.addListener(p)
      }
    }
    
    startTicker()
    
    return viewManager.baseUIView
  }
  
  private func startTicker() {
    let ticker = Ticker.sharedInstance()
    ticker.ticksPerSecond = fps
    ticker.logicCallback = updateLogic
    ticker.start()
    ticker.exitTime = CGFloat(60)
  }
  
  private var ourView : View {
    get {
      return ViewManager.sharedInstance().rootView
    }
  }
  
  // If user touches the sprite moving along the Hermite path, it will pause its motion until the touch ends
  //
  private func mainViewTouchHandler(touchEvent:TouchEvent, view:View) -> Bool {
    switch touchEvent.type {
    case .Down:
      if (!WITH_PATH) {
        break
      }
      let b = CGRect(x:pathLoc.x,y:pathLoc.y,width:128,height:64)
      if (b.contains(touchEvent.locationRelativeToView(view))) {
        paused = true
        return true
      }
    case .Up:
      if (paused) {
        paused = false
      }
    default:
      break
    }
  	return false
  }
  
  private var dragView : View!
  
  // ------------------------------------
  // Logic-related : state and behaviour
  //
  private let fps : CGFloat = 30.0
  private var frame : Int = 0
  private var pathLoc = CGPoint.zero
  private var paused = false
  private var pathFrame : Int = 0
	private var iconPanel : IconPanel!
  
  private func updateLogic() {
    frame += 1
    
    if (WITH_PATH) {
      if (!paused) {
        updatePathLoc()
        ourView.invalidate()
      }
    }
  }
  
  private func updatePathLoc() {
    
    if (path1 == nil) {
      let p1 = CGPoint(400,800)
      let p2 = CGPoint(600,120)
      let v1 = CGPoint(-300,0)
      let v2 = CGPoint(768,120)
      path1 = HermitePath(p1:p1,p2:p2,v1:v1,v2:v2)
      path2 = HermitePath(p1:p2,p2:p1,v1:v2,v2:v1)
    }
    
		pathFrame++
    
    let duration = fps * 4.2
    let f = Int(duration)
  	let q = pathFrame % (f * 2)
    
    var t : CGFloat
    var path : HermitePath
    
    if (q < f) {
    	t = CGFloat(q) / duration
    	path = path1
    } else {
      t = CGFloat(q-f) / duration
      path = path2
    }
    pathLoc = path.positionAt(t)
  }
  
  // Touch handler for the view that contains a smaller subview.  If user touches within the bounds
  // of the smaller subview, he can drag it around to a new location.
  //
  private func subviewTouchHandler(event:TouchEvent, view:View) -> Bool {
    let rel = event.locationRelativeToView(view)
    if event.type == .Down {
      if (dragView.bounds.contains(rel)) {
        let oper = DragSubviewOperation(view,subview:dragView,touchOffset:CGPoint.difference(dragView.bounds.origin,rel))
        oper.start(event)
        return true
			}
    }
    return false
  }

  // -------------------------------------------
  // Draw-related : renders current logic state
  
  private func mainViewPlotHandler(view : View) {
    prepareGraphics()
    bgndSprite.render(CGPoint.zero)
    if (WITH_PATH) {
	    blobSprite.render(pathLoc)
    }
  }
  
  private func updateSubview1(subview : View) {
    prepareGraphics()
    ballSprite.render(CGPoint.zero)
    
    // Draw some tinted sprites in this view, with some of them straddling
    // the view boundary (to verify that clipping is being done correctly)
    //
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
		ballSprite.render(CGPoint.zero)
  }
  
  // Prepare the graphics, if they haven't already been
  //
  private func prepareGraphics() {
    if (blobSprite != nil) {
      return
    }
    var texture = getTexture("blob")
    blobSprite = GLSprite(texture:texture, window:texture.bounds, program:nil)
    
    texture = getTexture("sample")
    texture.setRepeat(true)
    bgndSprite = GLSprite(texture:texture, window:CGRect(0,0,2000,2000), program:nil)
    
    texture = getTexture("AlphaBall")
		ballSprite = GLSprite(texture:texture, window:texture.bounds, program:nil)
    
    texture = getTexture("super")
    superSprite = GLSprite(texture:texture, window:texture.bounds, program:nil)
    
    texture = getTexture("tinted")
    tintedSprite = GLSprite(texture:texture, window:texture.bounds, program:GLTintedSpriteProgram.getProgram())

    if (WITH_ICONPANEL) {
      
      var i = 0
      let names = ["icon_a","icon_b","icon_d","icon_e"]
      var row : IconRow!
      
      // Generate
      var random = JSRandom(seed:12)
      for rowNumber in 0..<ICON_PANEL_TOTAL_ROWS {
        let count = random.randomInt(3) + 2
        row = iconPanel.addRow()
        for i in 0..<count {
          let q = random.randomInt(CInt(names.count))
          let name = names[Int(q)]
          
          let texture = getTexture(name)
          let sprite = GLSprite(texture:texture,window:texture.bounds,program:nil)
          let element = IconElement(name,texture.bounds.ptSize)
          row.addElement(element)
        }
      }
    }

  }
  
  // The original plot handler for the first IconPanel; we'll assume it's a static method
  // that can be used for both of our IconPanels
  private var originalIconPanelPlotHandler : View.PlotHandler!
  
  // Plot handler for our IconPanel.  Plot a background sprite, then call the original plot handler
  //
  private func iconPlotHandler(view : View) {
    prepareGraphics()
    ballSprite.render(CGPoint.zero)
    originalIconPanelPlotHandler(view)
  }

  private var textureMap = Dictionary<String,Texture>()
  private var blobSprite : GLSprite!
  private var bgndSprite : GLSprite!
  private var ballSprite : GLSprite!
  private var superSprite : GLSprite!
  private var tintedSprite : GLSprite!
  private var path1 : HermitePath!
  private var path2 : HermitePath!
  
  // Get texture from map; if it doesn't exist, create it
  //
  private func getTexture(name : String) -> Texture {
    var tex = textureMap[name]
    if tex == nil {
			tex = Texture(pngName:name)
      textureMap[name] = tex
    }
    return tex!
  }

  private func iconViewTextureProvider(name:String, size:CGPoint) -> Texture {
    return getTexture(name)
  }
  
  public class DragSubviewOperation : TouchOperation {
    public init(_ parentView:View, subview:View, touchOffset:CGPoint) {
      self.parentView = parentView
      self.subview = subview
      self.touchOffset = touchOffset
      super.init()
    }
    
    public override func processEvent(event: TouchEvent) {
      if (event.type == .Up) {
        complete()
      } else {
        let adjustedDragLocation = CGPoint.sum(event.locationRelativeToView(parentView),touchOffset)
        var subviewPositionLimit = CGRect(origin:CGPoint.zero,size:parentView.bounds.size)
        subviewPositionLimit.width -= subview.size.x
        subviewPositionLimit.height -= subview.size.y
        let padding : CGFloat = 20
        subviewPositionLimit.inset(dx:padding,dy:padding)
        subview.position = subviewPositionLimit.clampPoint(adjustedDragLocation)
        subview.invalidate()
      }
    }
    
    private var parentView : View
    private var subview : View
    private var touchOffset = CGPoint.zero
  }
  
}

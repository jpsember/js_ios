import GLKit
import OpenGLES

// TODO: can cached views contain other views (cached or no), and does this have any impact?

public class ViewManager : NSObject, GLKViewDelegate {
  
  public class func construct(bounds:CGRect) -> ViewManager {
  	ASSERT(S.singleton == nil,"ViewManager already constructed")
    S.singleton = ViewManager(bounds:bounds)
    return sharedInstance()
  }
  
  public class func sharedInstance() -> ViewManager {
    ASSERT(S.singleton != nil, "no ViewManager constructed")
    return S.singleton
  }
  
  private struct S {
    static var singleton : ViewManager!
  }
  
  private init(bounds : CGRect) {
    self.bounds = bounds
    super.init()
    
    buildBaseView()
  }
  
  private var bounds : CGRect

  // The UIView that contains the manager's views
  //
  private(set) var baseUIView : UIView!
  
  // The root view in the manager hierarchy
  //
  public var rootView : View! {
    didSet {
   		ASSERT(rootView.bounds == self.bounds,"expected root view bounds to equal the GLKView's")
    }
  }
  
  // If any views are invalid, request redraw of base UIView to redraw them
  //
  public func validate() {
    if (!allViewsValid(rootView)) {
    	baseUIView.setNeedsDisplay()
    }
  }
  
  public func handleTouchEvent(event : TouchEvent) {
    switch event.type {
    case .Down:
      // Find view that can respond to this event
      let responder = findResponderForDownEvent(event, view:rootView)
      if (responder != nil) {
      	touchEventActive = true
        touchEventView = responder
      }
    default:
      if !touchEventActive {
        break
      }
      if let handler = touchEventView.touchHandler {
        handler(event,touchEventView)
      } else {
        warning("no touch handler for \(event)")
      }
      // If there's a current operation, update it with this event
      if let oper = UserOperation.currentOperation() {
      	oper.update(event)
      }
    }
  }
  
  private func allViewsValid(rootView : View) -> Bool {
    var valid = rootView.renderedViewValid
    if (valid) {
	    for childView in rootView.children {
      	valid &= allViewsValid(childView)
      }
    }
    return valid
  }
  
  private func buildBaseView() {
    let view = ManagedGLKView(frame:bounds,manager:self)
    view.delegate = self
    baseUIView = view
  }
  
  // Manager's GLKViewDelegate; ideally would be private
  //
  public func glkView(view : GLKView!, drawInRect : CGRect) {
    let renderer = Renderer.sharedInstance()
    
    TextureTools.flushDeleteList()
    
    // Clear the GLKView 
    glClearColor(0, 0, 0, 1)
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    GLTools.verifyNoError()
    
    prepareGraphics(view.bounds.ptSize)
    
    // If a root view is defined, plot it
    if rootView == nil {
    	warning("no root view has been defined for ViewManager")
      return
    }
    
    renderer.defaultViewportSize = view.bounds.ptSize
    
  	plotAux(nil,rootView)
  }
  
  private func plotAux(parentView:View?, _ view:View) {
    // Update the origin relative to the root view
    var parentOrigin = CGPoint.zero
    if let parent = parentView {
      parentOrigin = parent.absolutePosition
    }
    view.absolutePosition = CGPoint.sum(parentOrigin,view.position)
    
  	view.plot()
    for v in view.children {
    	plotAux(view,v)
    }
  }
  
  private var preparedViewSize = CGPoint.zero

  private func prepareGraphics(viewSize : CGPoint) {
    // If previous size undefined, or different than new, invalidate old graphic elements
    if (preparedViewSize == viewSize) {
      return
    }
    preparedViewSize = viewSize
 		invalidateAllViews()
  }

  private func invalidateAllViews() {
    if (rootView != nil) {
    	invalidateSubtree(rootView)
    }
  }
  
  private func invalidateSubtree(rootView : View) {
    rootView.invalidate()
    for v in rootView.children {
      invalidateSubtree(v)
    }
  }
  
  private func findResponderForDownEvent(event : TouchEvent, view:View) -> View? {
    let rel = event.locationRelativeToView(view)
    let viewRect = CGRect(origin:CGPoint.zero, size:view.bounds.size)
    if (!viewRect.contains(rel)) {
      return nil
    }
    
    // First see if any child views will respond to this
    for child in view.children {
      let responder = findResponderForDownEvent(event,view:child)
      if (responder != nil) {
        return responder
      }
    }
    
    // Next, see if this view has a touch handler that can handle it
    if let handler = view.touchHandler {
      if (handler(event,view)) {
        // TODO: clarify what it means to respond to an event; i.e. returning true or false
      	return view
      }
    }
    return nil
  }
  
  // true if a touch event is being processed ('down' event has occurred, and no matching 'up' has yet occurred)
  private var touchEventActive  = false
  // View that responded to initial 'down' event (if touch event is active)
  private var touchEventView : View!
}

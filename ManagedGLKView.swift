import GLKit
import OpenGLES

// Our subclass of GLKView
public class ManagedGLKView : GLKView  {
  
  private var manager : ViewManager!
  
  public init(frame:CGRect, manager:ViewManager) {
    self.manager = manager
    let c = EAGLContext(API:EAGLRenderingAPI.OpenGLES2)
    super.init(frame:frame, context:c)
  }
  
  public required init(coder decoder: NSCoder) {
    super.init(coder: decoder)
  }
  
  public override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    // For test purposes only, delay exiting app if user activity detected
    Ticker.sharedInstance().resetInactivityCounter()
    manager.handleTouchEvent(TouchEvent(.Down,getTouchLocation(touches,event)))
  }
  
  public override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    manager.handleTouchEvent(TouchEvent(.Up,getTouchLocation(touches,event)))
  }
  
  public override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    manager.handleTouchEvent(TouchEvent(.Drag,getTouchLocation(touches,event)))
  }
  
  public func getTouchLocation(touches:NSSet, _ event:UIEvent) -> CGPoint {
    let touch : UITouch = event.allTouches()?.anyObject()! as UITouch
    let touchLocation = touch.locationInView(self)
    
    // Convert touch location to OpenGL coordinate system (origin is bottom left, not top left)
    return CGPoint(touchLocation.x, self.bounds.size.height - touchLocation.y)
  }
  
  public override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
    unimp("touchesCancelled")
  }
  
}


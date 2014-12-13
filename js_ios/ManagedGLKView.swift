import GLKit
import OpenGLES

// Our subclass of GLKView
public class ManagedGLKView : GLKView  {
  
  private var manager : ViewManager!
  
  // For testing 'touchesCancelled' code:
  // ----------------------------------------------------
  private var TestCancelDragCode = cond(true)
	private var dragOperationIndex = Int(0)
  private var dragOperationFrame = Int(0)
  private var cancelledFlag = false
  // ----------------------------------------------------
  
  public init(frame:CGRect, manager:ViewManager) {
    self.manager = manager
    let c = EAGLContext(API:EAGLRenderingAPI.OpenGLES2)
    super.init(frame:frame, context:c)
  }
  
  public required init(coder decoder: NSCoder) {
    super.init(coder: decoder)
  }
  
  public override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    if TestCancelDragCode {
      cancelledFlag = false
      dragOperationFrame = 0
      dragOperationIndex += 1
    }
    
    // For test purposes only, delay exiting app if user activity detected
    Ticker.sharedInstance().resetInactivityCounter()
    manager.handleTouchEvent(TouchEvent(.Down,getTouchLocation(touches,event)))
  }
  
  public override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    if TestCancelDragCode {
      if cancelledFlag {
        return
      }
    }
    manager.handleTouchEvent(TouchEvent(.Up,getTouchLocation(touches,event)))
  }
  
  public override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    if TestCancelDragCode {
      if cancelledFlag {
        return
      }
      if (dragOperationIndex % 3 == 0) {
      	dragOperationFrame++
        if dragOperationFrame == 45 {
          cancelledFlag = true
          warning("simulating touchesCancelled \(dragOperationIndex)")
          touchesCancelled(touches,withEvent:event)
          return
        }
      }
    }
    
    manager.handleTouchEvent(TouchEvent(.Drag,getTouchLocation(touches,event)))
  }
  
  public func getTouchLocation(touches:NSSet, _ event:UIEvent) -> CGPoint {
    let touch : UITouch = event.allTouches()?.anyObject()! as UITouch
    let touchLocation = touch.locationInView(self)
    
    // Convert touch location to OpenGL coordinate system (origin is bottom left, not top left)
    return CGPoint(touchLocation.x, self.bounds.size.height - touchLocation.y)
  }
  
  public override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
    TouchOperation.currentOperation().cancel()
  }
  
}


import GLKit
import OpenGLES

// Our subclass of GLKView
public class ManagedGLKView : GLKView  {
  
  public override init(frame:CGRect) {
    let c = EAGLContext(API:EAGLRenderingAPI.OpenGLES2)
    super.init(frame:frame, context:c)
  }
  
  public required init(coder decoder: NSCoder) {
    super.init(coder: decoder)
  }
  
  public override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    // For test purposes only, delay exiting app if user activity detected
    Ticker.sharedInstance().resetInactivityCounter()
    let event = TouchEvent(.Down,getTouchLocation(touches,event))
    puts("\(event)")
  }
  
  public override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    let event = TouchEvent(.Up,getTouchLocation(touches,event))
    puts("\(event)")
  }
  
  public override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    let event = TouchEvent(.Drag,getTouchLocation(touches,event))
    puts("\(event)")
  }
  
  public func getTouchLocation(touches:NSSet, _ event:UIEvent) -> CGPoint {
    let touch : UITouch = event.allTouches()?.anyObject()! as UITouch
    let touchLocation = touch.locationInView(self)
    return touchLocation
  }
  
  public override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
    unimp("touchesCancelled")
  }
  
}



let STATE_RUNNING = 0
let STATE_COMPLETED = 1
let STATE_CANCELLED = 2

public class TouchOperation : NSObject {
  
  public var state = STATE_RUNNING
  
  // Get the current operation; will always be defined, by using a default 'do-nothing'
  // operation if no other operation is active
  //
  public class func currentOperation() -> TouchOperation {
    if (S.currentOperation == nil) {
      S.currentOperation = DefaultOperation.sharedInstance()
    }
    return S.currentOperation
  }

  // Make the operation the current operation, and set it running;
  // call processEvent with the given event
  //
  public func start(event : TouchEvent) {
    TouchOperation.setCurrent(self)
    state = STATE_RUNNING
    processEvent(event)
  }
  
  // Process a touch event; default implementation does nothing
  //
  public func processEvent(touchEvent:TouchEvent) {
  }
  
  // If operation is currently running, set its state to COMPLETED, and set the default operation
  //
  public func complete() {
    if (self.state == STATE_RUNNING) {
      self.state = STATE_COMPLETED
      TouchOperation.setCurrent(nil)
    }
  }
  
  // If operation is currently running, set its state to CANCELLED, and set the default operation
  //
  public func cancel() {
    if (self.state == STATE_RUNNING) {
      self.state = STATE_CANCELLED
      TouchOperation.setCurrent(nil)
    }
  }
  
  // Render a cursor for the current operation, within the root view;
  // default implementation does nothing
  //
  public func updateCursor(location:CGPoint) {
  }
  
  private class func setCurrent(operation:TouchOperation?) {
    var oper = operation
    if (oper == nil) {
      oper = DefaultOperation.sharedInstance()
    }
    let curr = currentOperation()
    if curr != oper {
      curr.cancel()
      S.currentOperation = oper
    }
  }
  
  private struct S {
    static var currentOperation : TouchOperation!
  }

  public class DefaultOperation : TouchOperation {
    public class func sharedInstance() -> DefaultOperation {
      if (S.singleton == nil) {
        S.singleton = DefaultOperation()
      }
      return S.singleton
    }
    
    private struct S {
      static var singleton : DefaultOperation!
    }
  }

}

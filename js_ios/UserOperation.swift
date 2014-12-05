
let STATE_RUNNING = 0
let STATE_COMPLETED = 1
let STATE_CANCELLED = 2

public class UserOperation : NSObject {
  
  public var state = STATE_RUNNING
  
//	// TODO: we need a way to allow different views to render a particular operation
//  public func render() {
//  }
  
  // If operation is currently running, set its state to CANCELLED, and set the null operation
  public func cancel() {
    if (self.state == STATE_RUNNING) {
      self.state = STATE_CANCELLED
      UserOperation.setCurrent(nil)
    }
  }
  
  // Process an event
  public func processEvent(touchEvent:TouchEvent) {
//    puts("processEvent \(self): \(touchEvent)")
  }

  // Render a cursor for the current operation, within the root view;
  // default implementation does nothing
  //
  public func updateCursor(location:CGPoint) {
  }
  
  // If operation is currently running, set its state to COMPLETED, and set the null operation
  //
  public func complete() {
    if (self.state == STATE_RUNNING) {
  		self.state = STATE_COMPLETED
      UserOperation.setCurrent(nil)
    }
  }
  
  // Make the operation the current operation, and set it running
  //
  public func start(touchEvent:TouchEvent) {
    UserOperation.setCurrent(self)
    state = STATE_RUNNING
  }
  
  private class func setCurrent(operation:UserOperation?) {
    var oper = operation
    if (oper == nil) {
      oper = DefaultOperation.sharedInstance()
    }
    let curr = currentOperation()
    if curr != oper {
//      puts("UserOperation.setCurrent, was \(curr), new \(operation)")
      curr.cancel()
      S.currentOperation = oper
    }
  }
  
  public class func currentOperation() -> UserOperation {
    if (S.currentOperation == nil) {
      S.currentOperation = DefaultOperation.sharedInstance()
    }
    return S.currentOperation
  }
  
  private struct S {
    static var currentOperation : UserOperation!
  }

}

public class DefaultOperation : UserOperation {
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



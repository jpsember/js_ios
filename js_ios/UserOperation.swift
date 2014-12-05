
let STATE_RUNNING = 0
let STATE_COMPLETED = 1
let STATE_CANCELLED = 2

public class UserOperation : NSObject {
  
  public class func setViewManager(manager : ViewManager) {
    S.viewManager = manager
  }
  
  public class func tempUpdateRootView() {
    if (S.viewManager != nil) {
      S.viewManager!.rootView.invalidate()
    }
  }
  
  private struct S {
    static var currentOperation : UserOperation?
    static var viewManager : ViewManager?
  }

  public var state = STATE_RUNNING
  
  public func render() {
  }
  
  public func cancel() {
    ASSERT(self == S.currentOperation)
    if (self.state == STATE_RUNNING) {
      self.state = STATE_CANCELLED
    }
    UserOperation.setCurrent(nil)
  }
  
  public func update(touchEvent:TouchEvent) {
  }

  public func start(touchEvent:TouchEvent) {
  }

  public func complete() {
    ASSERT(self == S.currentOperation)

    if (self.state == STATE_RUNNING) {
  		self.state = STATE_COMPLETED
    }
  	UserOperation.setCurrent(nil)
  }
  
  public class func start(operation:UserOperation,touchEvent:TouchEvent) {
    setCurrent(operation)
    operation.start(touchEvent)
  }
  
  private class func setCurrent(operation:UserOperation?) {
    if let currentOperation = S.currentOperation {
      if (currentOperation.state == STATE_RUNNING) {
      	currentOperation.cancel()
      }
    }
    S.currentOperation = operation
  }
  
  public class func currentOperation() -> UserOperation? {
    return S.currentOperation
  }
  
}

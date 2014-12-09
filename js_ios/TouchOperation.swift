public class TouchOperation : NSObject {
  
  public enum State : Printable {
  	case Running
    case Completed
    case Cancelled
    
    // This is kind of painful; can't find an automatic way of generating these strings
    public var description : String {
        switch self {
        case .Running: return "Running"
        case .Completed: return "Running"
        case .Cancelled: return "Cancelled"
      }
    }

  }
  
  private var state = State.Cancelled
  public var running : Bool {
    get {
      return state == .Running
    }
  }

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
    processEvent(event)
  }
  
  // Update operation for logic tick; default implementation does nothing
  //
  public func updateLogic() {
  }
  
  // Process a touch event; default implementation does nothing
  //
  public func processEvent(touchEvent:TouchEvent) {
  }
  
  // If operation is currently running, set its state to COMPLETED, and set the default operation
  //
  public func complete() {
    if (running) {
      state = .Completed
      TouchOperation.setCurrent(nil)
    }
  }
  
  // If operation is currently running, set its state to CANCELLED, and set the default operation
  //
  public func cancel() {
    if (running) {
      state = .Cancelled
      TouchOperation.setCurrent(nil)
    }
  }
  
  // Render a cursor for the current operation, within the root view;
  // default implementation does nothing
  //
  public func updateCursor(location:CGPoint) {
  }
  
  private class func setCurrent(operation:TouchOperation!) {
    var oper = operation
    if (oper == nil) {
      oper = DefaultOperation.sharedInstance()
    }
    currentOperation().cancel()
    S.currentOperation = oper
    oper.state = .Running
  }
  
  private struct S {
    static var currentOperation : TouchOperation!
  }

  public class DefaultOperation : TouchOperation {
    public class func sharedInstance() -> DefaultOperation {
      if (S.singleton == nil) {
        S.singleton = DefaultOperation()
        let r = State.Running
      }
      return S.singleton
    }
    
    private struct S {
      static var singleton : DefaultOperation!
    }
  }

}

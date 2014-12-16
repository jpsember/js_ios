public class TouchOperation : NSObject, LogicProtocol {
  
  // Public elements
  
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
  
  // Process a touch event; default implementation passes event to listeners
  //
  public func processEvent(touchEvent:TouchEvent) {
    for item : AnyObject in listeners {
      let touchListener = item as TouchListener
      touchListener.processTouchEvent(touchEvent)
    }
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
  
  public func addListener(listener : TouchListener) {
    listeners.addObject(listener)
  }
  
  public func removeListener(listener : TouchListener) {
    listeners.removeObject(listener)
  }
  
  // Private elements
  
  private var state = State.Cancelled
  private var listeners : NSMutableSet = NSMutableSet() //Array<TouchListener> = []
  
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

  internal class DefaultOperation : TouchOperation {
    class func sharedInstance() -> DefaultOperation {
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

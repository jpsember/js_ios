import Foundation

public class Ticker : NSObject {

  public typealias Callback = () -> Void
  
  public var ticksPerSecond : CGFloat = 30
  public var elapsedTime : CGFloat {
    get {
      return CGFloat(totalTicks) / ticksPerSecond
    }
  }
  private var timeSinceLastActivity : CGFloat = 0
  
  public var logicCallback : Callback!
  // For development purposes only; if > 0, exits app after this amount of time
  public var exitTime = CGFloat(0)
  
  public class func sharedInstance() -> Ticker {
    if (S.singleton == nil) {
      S.singleton = Ticker()
    }
    return S.singleton
  }
  
  public func start() {
    ASSERT(logicCallback != nil,"no logic callback defined")
    var timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1.0 /  ticksPerSecond ), target:self, selector: Selector("tickerTimerCallback"), userInfo: nil, repeats: true)
  }

  public func tickerTimerCallback() {
    totalTicks++
    
    if (exitTime > 0) {
      if (elapsedTime - timeSinceLastActivity >= exitTime) {
        exitApp()
      }
    }
    
    TouchOperation.currentOperation().updateLogic()
    let m = ViewManager.sharedInstance()
    m.updateLogicListeners()
    
    logicCallback()
    
    m.validate()
  }

  public func resetInactivityCounter() {
  	timeSinceLastActivity = elapsedTime
  }
  
  private struct S {
    static var singleton : Ticker!
  }
  
  private var totalTicks = 0
  
}


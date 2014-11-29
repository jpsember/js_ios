import Foundation

public class Ticker : NSObject {

  public typealias Callback = () -> Void
  
  public var ticksPerSecond : CGFloat = 30
  public var elapsedTime : CGFloat {
    get {
      return CGFloat(totalTicks) / ticksPerSecond
    }
  }
  public var logicCallback : Callback!
  public var renderCallback : Callback!
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
    ASSERT(renderCallback != nil,"no render callback defined")
    
    var timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1.0 /  ticksPerSecond ), target:self, selector: Selector("tickerTimerCallback"), userInfo: nil, repeats: true)
  }

  public func tickerTimerCallback() {
    totalTicks++
    
    if (exitTime > 0) {
      if (elapsedTime >= exitTime) {
        exitApp()
      }
    }
    
    logicCallback()
    renderCallback()
  }

  private struct S {
    static var singleton : Ticker!
  }
  
  private var totalTicks = 0
  
}


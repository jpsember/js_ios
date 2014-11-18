import Foundation
import GLKit

public class AppDelegate : UIResponder, UIApplicationDelegate {
  
  public var window : UIWindow?
  
  public func getMainViewColor() -> UIColor {
    return UIColor.blueColor()
  }
  
  public func application(application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
      constructWindow()
      // Don't construct a view or view controller if in test mode
  		if (JSBase.testModeActive()) {
        self.window!.backgroundColor = UIColor.grayColor()
        return true
      }
      buildViewController()
      let r = CGRect(1,2,3,4)
      let p = CGPoint(1,2)
      
      d(34.23)
      
      DebugTools.dRect(r)
      
      puts("r=\(d(r)) p=\(d(p)) val=\(d(123.423))")
      return true
  }
  
  public func constructWindow() {
    let window = UIWindow(frame:UIScreen.mainScreen().bounds)
    window.backgroundColor = UIColor.whiteColor()
    window.makeKeyAndVisible()
    self.window = window
  }
  
  public func buildView() -> UIView {
    return UIView(frame:self.window!.bounds)
  }
  
  public func buildViewController() {
    let view = buildView()
    let viewController = UIViewController()
    viewController.view = view
    window!.rootViewController = viewController
  }
  
  public func applicationWillResignActive(application: UIApplication) {
  }
  
  public func applicationDidEnterBackground(application: UIApplication) {
  }
  
  public func applicationWillEnterForeground(application: UIApplication) {
  }
  
  public func applicationDidBecomeActive(application: UIApplication) {
  }
  
  public func applicationWillTerminate(application: UIApplication) {
  }
}

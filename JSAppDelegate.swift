import Foundation

public class JSAppDelegate : UIResponder, UIApplicationDelegate {
  
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

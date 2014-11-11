import GLKit

@UIApplicationMain // Allows us to omit a main.m file
public class GLAppDelegate : JSAppDelegate, GLKViewDelegate {
    
    override public func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
            constructWindow()
            buildViewAndViewController()
            return true
    }
    
    public func glkView(view : GLKView!, drawInRect : CGRect) {
        // A nice green color
        glClearColor(0.0, 0.5, 0.1, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }
    
    func constructWindow() {
        window = UIWindow(frame:UIScreen.mainScreen().bounds)
        window.backgroundColor = UIColor.whiteColor()
        window.makeKeyAndVisible()
    }
    
    func buildViewAndViewController() {
        let view = JSGLView(frame:self.window.bounds)
        view.delegate = self
        
        let viewController = UIViewController()
        viewController.view = view
        window.rootViewController = viewController
    }
    
}

#import "JSGLAppDelegate.h"
#import "JSGLKView.h"

#import "js_ios-Swift.h"
#import "JSBase.h"

@implementation JSGLAppDelegate

- (void)constructWindow {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    JSExperiment *exp = [[JSExperiment alloc] init];
    DBG
    pr(@"Built JSExperiment %@, frame rate %f\n",exp,exp.frameRate);
}

- (void)buildViewController {
    // Build a root view controller
    UIViewController *viewController = [[UIViewController alloc] init];
    JSGLKView *view = [JSGLKView viewWithFrame:self.window.bounds];
    view.delegate = self;
    [viewController setView:view];
    [self.window setRootViewController:viewController];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self constructWindow];
    [self buildViewController];
    return YES;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // A nice green color
    glClearColor(0.0,.5,.1, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
}

@end

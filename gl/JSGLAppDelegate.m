#import "JSGLAppDelegate.h"
#import "JSGLKView.h"

@implementation JSGLAppDelegate

- (void)constructWindow {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
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
    glClearColor(1.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
}

@end

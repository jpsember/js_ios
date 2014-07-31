#import "JSBase.h"

@interface JSTestAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

@implementation JSTestAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  // Override point for customization after application launch.
  self.window.backgroundColor = [UIColor whiteColor];
  [self.window makeKeyAndVisible];
  
  // Build a basic root view and controller to satisfy iOS warning
  {
    UIViewController *vc = [[UIViewController alloc] init];
    
    CGRect f = CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height);
    
    UIView *v = [[UIView alloc] initWithFrame:f];
    [v setBackgroundColor:[UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1]];
    
    [vc setView:v];
    
    [self.window setRootViewController:vc];
  }
  
  return YES;
}


@end


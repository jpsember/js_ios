// Convenience class that implements the UIApplicationDelegate, and
// constructs a basic view controller with a single UIView of a particular color.

@interface JSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Override this to choose a view color that is something other than the default (blue)
- (UIColor *)getMainViewColor;

@end

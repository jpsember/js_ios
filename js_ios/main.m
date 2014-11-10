#import "JSBase.h"
#import "JSGLAppDelegate.h"

int main(int argc, char *argv[]) {
    @autoreleasepool {
        @try {
            NSString *appDelegateName;
#if DEBUG
            if ([JSBase testModeActive])
                appDelegateName = @"JSTestAppDelegate";
            else
#endif
                appDelegateName = NSStringFromClass([JSGLAppDelegate class]);
            DBG
            pr(@"appDelegateName %@\n", appDelegateName);
            return UIApplicationMain(argc, argv, nil, appDelegateName);
        } @catch (JSDieException *e) {
            NSLog(@"Terminating:\n%@", e);
        }
    }
    return 0;
}

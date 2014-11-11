#import "JSBase.h"
#import "js_ios-Swift.h"

int main(int argc, char *argv[]) {
    @autoreleasepool {
        @try {
            NSString *appDelegateName;
#if DEBUG
            if ([JSBase testModeActive])
                appDelegateName = @"JSTestAppDelegate";
            else
#endif
                appDelegateName = NSStringFromClass([GLAppDelegate class]);
            return UIApplicationMain(argc, argv, nil, appDelegateName);
        } @catch (JSDieException *e) {
            NSLog(@"Terminating:\n%@", e);
        }
    }
    return 0;
}

#import "JSBase.h"
#import "JSAppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        @try {
          NSString *appDelegateName;
#if DEBUG
          if ([JSBase testModeActive])
            appDelegateName = @"JSTestAppDelegate";
          else
#endif
            appDelegateName = NSStringFromClass([JSAppDelegate class]);
          DBG
          pr(@"appDelegateName %@\n",appDelegateName);
          return UIApplicationMain(argc, argv, nil, appDelegateName);
        } @catch (JSDieException *e) {
          NSLog(@"Terminating:\n%@",e);
        }
    }
}

#import "JSBase.h"

#import "B.h"

@implementation B
+ (int)showMe:(NSString *)message {
	DBG
  pr(@"showMe: %@\n",message);
  return 5;
}


@end

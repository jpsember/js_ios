// A class callable from .swift file
// must add '#import "B.h"' to js_ios-Bridging-Header.h

#import <Foundation/Foundation.h>

@interface B : NSObject

+ (int)showMe:(NSString *)message;

@end

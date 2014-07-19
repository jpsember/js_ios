#import "JSBase.h"
#import "NSUserDefaults+JSUserDefaultsCategory.h"

@implementation NSUserDefaults (JSUserDefaultsCategory)

- (BOOL)_hasKey:(NSString *)key {
  return [self objectForKey:key] != nil;
}

- (id)objectForKey:(NSString *)key or:(id)v {
  return [self _hasKey:key] ? [self objectForKey: key] : v;
}

- (NSString *)stringForKey:(NSString *)key or:(NSString *)v {
  return [self _hasKey:key] ? [self stringForKey:key] : v;
}

- (NSInteger)integerForKey:(NSString *)key or:(NSInteger)v {
  return [self _hasKey:key] ? [self integerForKey:key] : v;
}

- (CGFloat)floatForKey:(NSString *)key or:(CGFloat)v {
  return [self _hasKey:key] ? [self floatForKey:key] : v;

}

- (BOOL)boolForKey:(NSString *)key or:(BOOL)v {
  return [self _hasKey:key] ? [self boolForKey:key] : v;
}

static NSTimeInterval synchronizationDelay = 0;

+ (void)_defaultsChanged:(NSNotification *)notification {
//  DBG
  pr(@"Defaults has changed\n");
  @synchronized(self) {
    static NSTimeInterval previousUpdate;
    NSTimeInterval t = CACurrentMediaTime();
    pr(@" delay since last written=%f\n",(t-previousUpdate));

    if (fabs(t-previousUpdate) > synchronizationDelay) {
      previousUpdate = t;
      pr(@"  doing synchronize after delay\n");
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, synchronizationDelay * NSEC_PER_SEC),
                     dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                       pr(@"  doing synchronize\n");
          [NSStandardUserDefaults synchronize];
      });
    }
  }
}

+ (void)setSynchronizeDelay:(NSTimeInterval)delay {
  @synchronized(self) {
//    DBG
    pr(@"Changing sync delay from %f to %f\n",synchronizationDelay,delay);
    BOOL delayChanging = (delay != synchronizationDelay);
    synchronizationDelay = delay;
    if (delayChanging) {
      NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
      if (!delay) {
        pr(@" removing observer\n");
        [center removeObserver:self];
      } else {
        pr(@" adding observer\n");
        [center addObserver:self
                   selector:@selector(_defaultsChanged:)
                       name:NSUserDefaultsDidChangeNotification
                     object:nil];
      }
    }
  }
}

@end

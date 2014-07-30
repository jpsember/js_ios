#if DEBUG

@interface JSMemoryMonitor : NSObject

@property (nonatomic, assign) BOOL stackTracesEnabled;

+ (JSMemoryMonitor *)sharedInstance;
- (id)objectConstructed:(id)object;
- (void)setMaximumInstancesFor:(Class)theClass to:(int)m;
- (void)setTraceFor:(Class)theClass to:(BOOL)status;
- (void)reset;

/*
 The name of exceptions thrown by this API
 */
+ (NSString *)exceptionName;

@end

// Debug-only subclass of NSObject that allows tracking object lifetimes

@interface JSObject : NSObject

@property (nonatomic, strong) id memoryMonitorObject;

@end

#define JSSharedMemoryMonitor [JSMemoryMonitor sharedInstance]

#else

#define JSObject NSObject

#endif


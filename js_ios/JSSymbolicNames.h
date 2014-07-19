#if DEBUG

@interface JSSymbolicNames : NSObject

// These methods are thread-safe.
- (NSString *)nameFor:(const void *)ptr;
- (NSString *)nameForId:(id)object;
- (void)reset;

@end

#endif

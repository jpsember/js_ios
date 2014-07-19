@interface JSQueue : NSObject <JSPushPopProtocol, NSFastEnumeration>

// By default, items are pushed to the REAR of the queue,
// and popped from the FRONT.
// Also by default, peeking occurs relative to the FRONT of the queue.
//

@property (nonatomic, assign, readonly) NSUInteger count;

+ (JSQueue *)queue;
+ (JSQueue *)queueWithArray:(NSArray *)array;
+ (JSQueue *)queueWithCapacity:(NSUInteger)capacity;

- (void)clear;
- (BOOL)isEmpty;
- (id)pop;
- (void)push:(id)item;
- (void)push:(id)item toFront:(BOOL)toFront;
- (id)peek;
- (id)peekAtFront:(BOOL)atFront;
- (id)peekAtFront:(BOOL)atFront distance:(NSUInteger)distance;

- (id)pop:(BOOL)fromFront;

@end

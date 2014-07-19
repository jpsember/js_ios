@protocol JSPushPopProtocol <NSObject>

- (void)push:(id)item;
- (id)pop;
- (BOOL)isEmpty;
//- (NSUInteger)count;  //Perhaps this is unnecessary?

@end

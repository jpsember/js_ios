@interface JSOrderedSet : NSObject

@property (nonatomic, assign, readonly) NSUInteger count;

+ (JSOrderedSet *)setWithComparator:(NSComparator)cmp;
- (instancetype)initWithComparator:(NSComparator)cmp;
- (void)setComparator:(NSComparator)cmp;
- (BOOL)containsItem:(id)item;
- (BOOL)containsItem:(id)item index:(NSUInteger *)index;
- (BOOL)isEmpty;
- (id)firstItem;
- (id)lastItem;

// Determine the item A that would immediately precede an item B,
// if B were to be in the set.  Returns YES if there was such an item, or
// NO if B would be the first item in the set.
- (BOOL)itemPreceding:(id)item index:(NSUInteger *)index;

// Determine the item A that would immediately follow an item B,
// if B were to be in the set.  Returns YES if there was such an item, or
// NO if B would be the last item in the set.
- (BOOL)itemFollowing:(id)item index:(NSUInteger *)index;

// Returns true if item already existed
- (BOOL)addItem:(id)item;
- (BOOL)addItem:(id)item mustNotExist:(BOOL)f;

- (BOOL)removeItem:(id)item;
- (BOOL)removeItem:(id)item mustExist:(BOOL)f;
- (NSEnumerator *)objectEnumerator;
- (id)objectAtIndex:(NSUInteger)index;
- (void)removeAllObjects;

@end

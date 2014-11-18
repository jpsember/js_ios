#import "JSBase.h"
#import "js_ios-Swift.h"

@interface JSOrderedSet ()

@property (nonatomic, strong) NSComparator comparator;
@property (nonatomic, strong) NSMutableOrderedSet *nsSet;

@end

@implementation JSOrderedSet

- (NSUInteger)count{
    return [_nsSet count];
}

- (BOOL)isEmpty {
  return [self count] == 0;
}

- (id)firstItem {
  ASSERT(![self isEmpty],@"set is empty");
  return [_nsSet firstObject];
}

- (id)lastItem {
  ASSERT(![self isEmpty],@"set is empty");
  return [_nsSet lastObject];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [_nsSet objectAtIndex:index];
}

+ (JSOrderedSet *)setWithComparator:(NSComparator)cmp {
    return [[JSOrderedSet alloc] initWithComparator:cmp];
}

- (instancetype)initWithComparator:(NSComparator)cmp {
    if (self = [super init]) {
        _comparator = cmp;
        _nsSet = [[NSMutableOrderedSet alloc] init];
    }
    return self;
}

- (NSUInteger) _indexOfItem:(id)item {
    return [_nsSet indexOfObject:item inSortedRange:NSMakeRange(0,[self count]) options:NSBinarySearchingFirstEqual
                 usingComparator:_comparator];
}

- (NSUInteger) _insertionIndexOfItem:(id)item {
    return [_nsSet indexOfObject:item
                   inSortedRange:NSMakeRange(0,[self count])
                         options:NSBinarySearchingInsertionIndex
                 usingComparator:_comparator];
}

- (BOOL)containsItem:(id)item {
    return [self containsItem:item index:NULL];
}

- (BOOL)containsItem:(id)item index:(NSUInteger *)indexPtr {
    NSUInteger index = [self _indexOfItem:item];
    if (indexPtr) {
        *indexPtr = index;
    }
    return index != NSNotFound;
}

- (BOOL)addItem:(id)item {
    return [self addItem:item mustNotExist:NO];
}

- (void)removeAllObjects {
  [_nsSet removeAllObjects];
}

- (BOOL)addItem:(id)item mustNotExist:(BOOL)mustNotExist {
//  DBG
  pr(@"addItem %@ mustNotExist %@\n",item,dBool(mustNotExist));
  
    BOOL found = NO;
    
    NSUInteger index = [self _insertionIndexOfItem:item];
    if (index != [self count]) {
        id item2 = [_nsSet objectAtIndex:index];
        if (_comparator(item,item2) == NSOrderedSame) {
            found = YES;
            if (mustNotExist) {
                die(@"addItem already exists:\n  new     =%@\n  existing=%@\n",item,item2);
            }
        }
    }
    if (!found) {
      pr(@" did not already exist, inserting at index %d (total %d)\n",index,_nsSet.count);
        [_nsSet insertObject:item atIndex:index];
    }
    return found;
}

- (BOOL)removeItem:(id)item {
    return [self removeItem:item mustExist:NO];
}

- (BOOL)removeItem:(id)item mustExist:(BOOL)mustExist {
    NSUInteger index;
    BOOL found = [self containsItem:item index:&index];
    if (found) {
        [_nsSet removeObjectAtIndex:index];
    } else if (mustExist) {
        die(@"removeItem does not exist: %@",item);
    }
    return found;
}

- (NSEnumerator *)objectEnumerator {
    return [_nsSet objectEnumerator];
}

#if DEBUG
- (NSString *)description {
  NSUInteger count = MIN([self count],50);
  NSMutableString *s = [NSMutableString stringWithFormat:@"JSOrderedSet (%d items) [\n",(int)self.count];
  NSEnumerator *enumerator = [self objectEnumerator];
  for (int i = 0; i < count; i++) {
    id obj = [enumerator nextObject];
    NSString *s2 = [obj description];
    [s appendFormat:@" %@\n",s2];
  }
  if (count < [self count]) {
    [s appendFormat:@" ... and %d more\n",(int)(self.count  - count)];
  }
  [s appendString:@"]"];
  return s;
}
#endif



- (BOOL)itemPreceding:(id)item index:(NSUInteger *)index {
  
  // Use a wrapper for the existing comparator that returns +1 for anything equal or above,
  // and 0 for anything less; and use the 'last equal' search options
  
  NSUInteger pos = [_nsSet indexOfObject:item
                 inSortedRange:NSMakeRange(0,[self count])
                       options:NSBinarySearchingLastEqual
                  usingComparator:^NSComparisonResult(id obj1, id obj2) {
                    NSComparisonResult r = _comparator(obj1,obj2);
                    return (r < 0) ? NSOrderedSame : NSOrderedDescending;
                  }];
  if (pos == NSNotFound)
    return NO;
  *index = pos;
  return YES;
}


- (BOOL)itemFollowing:(id)item index:(NSUInteger *)index {
  // Use a wrapper for the existing comparator that returns -1 for anything equal or below,
  // and 0 for anything above; and use the 'first equal' search options
  
  NSUInteger pos = [_nsSet indexOfObject:item
                    inSortedRange:NSMakeRange(0,[self count])
                          options:NSBinarySearchingFirstEqual
                  usingComparator:^NSComparisonResult(id obj1, id obj2) {
                    NSComparisonResult r = _comparator(obj1,obj2);
                    return (r > 0) ? NSOrderedSame : NSOrderedAscending;
                  }];
  if (pos == NSNotFound)
    return NO;
  *index = pos;
  return YES;

}

@end


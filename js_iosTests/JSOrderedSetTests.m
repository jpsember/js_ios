#import "JSTestUtil.h"


@interface MySortedObject : NSObject

@property (nonatomic, assign) int type;
@property (nonatomic, assign) int value;

@end

@implementation MySortedObject

- (NSString *)description {
  return [NSString stringWithFormat:@"(MySortedObject type=%d value=%3d)",_type,_value];
}
@end


@interface JSOrderedSetTests : JSTestCase

@property (nonatomic, strong) JSOrderedSet *set;
@property (nonatomic, strong) id comparator;
@property (nonatomic, assign) int numComparisons;
@property (nonatomic, strong) NSMutableSet *generatedElements;
@property (nonatomic, strong) NSArray *orderedElements;

@end


@implementation JSOrderedSetTests

- (void)setUp {
    [super setUp];
    JSOrderedSetTests *os = self;
    _comparator = ^NSComparisonResult(id obj1, id obj2) {
        // DBG
        NSComparisonResult r = [obj1 compare:obj2];
        pr(@"comparing %@ with %@ = %d\n",obj1,obj2,r);
        os.numComparisons++;
        return r;
    };
    [self reset];
}

- (NSString *)generate {
    NSString *s;
    while (true) {
        s = [NSString stringWithFormat:@"%d",[self.random randomInt:9000000]+1000000];
        if (![_generatedElements containsObject:s])
            break;
    }
    [_generatedElements addObject:s];
  _orderedElements = nil;
    return s;
}

- (NSArray *)orderedElements {
  if (!_orderedElements) {
    _orderedElements = [[_generatedElements allObjects] sortedArrayUsingComparator:_comparator];
  }
  return _orderedElements;
}

- (void)add:(NSString *)item {
    [_set addItem:item mustNotExist:YES];
}

- (void)populate:(NSUInteger)count{
    [self populate:count set:_set];
}

- (void)populate:(NSUInteger)count set:(JSOrderedSet *)set {
    for (int i = 0; i < count; i++) {
        [self add:[self generate]];
    }
}

- (NSString *)show{
    return [self show:_set];
}

- (NSString *)show:(JSOrderedSet *)set {
    NSMutableString *s = [NSMutableString stringWithString:@"[ "];
    
    for (NSString *item in [set objectEnumerator]) {
        [s appendFormat:@"%@ ",item];
    }
    [s appendString:@"]"];
    return s;
}

#if DEBUG
- (void)testAddedElements {
    DBG
    [JSIORecorder start];
    [self populate:20];
    pr(@"%@\n",[self show]);
    [JSIORecorder stop];
}
#endif

- (void)reset {
    _numComparisons = 0;
    _set = [JSOrderedSet setWithComparator:_comparator];
    [_set count];
    
    _generatedElements = [NSMutableSet set];
  _orderedElements = nil;
}

- (void)testDoesntContainItem {
    [self populate:20];
      XCTAssert(![_set containsItem:[self generate]],@"object should not have been found");
}

- (void)testContainsItem {
    [self populate:20];
    for (NSString *item in _generatedElements) {
        XCTAssert([_set containsItem:item]);
        
        NSUInteger index;
        XCTAssert([_set containsItem:item index:&index]);
        XCTAssertEqualObjects([_set objectAtIndex:index],item,@"objects not equal");
    }
}

- (void)testFirst {
  [self populate:20];
  for (int i = 0; i < 20; i++) {
    id item = [_set firstItem];
    XCTAssert(![_set isEmpty]);
    [_set removeItem:item];
  }
  XCTAssert([_set isEmpty]);
}

#if DEBUG
- (void)testAttemptRemoveFirstFromEmpty {
  [self populate:1];
  [_set removeItem:[_set firstItem]];
  XCTAssertExceptionWithSubstring(@"set is empty" ,^{[_set firstItem];});
}
#endif

- (void)testAddExistingElement {
    id item = [self generate];
    BOOL exist1 = [_set addItem:item];
    BOOL exist2 = [_set addItem:item];
    XCTAssert(!exist1,@"should not have existed");
    XCTAssert(exist2,@"should have existed");
}

- (void)testAddExistingElementDisallowed {
  id item = [self generate];
  [_set addItem:item];
  XCTAssertExceptionWithSubstring(@"!already exists" ,^{[_set addItem:item mustNotExist:YES];});
}

- (void)testRemoveExistingElement {
    id item = [self generate];
    BOOL exist1 = [_set addItem:item];
    BOOL exist2 = [_set removeItem:item];
    XCTAssert(!exist1,@"should not have existed");
    XCTAssert(exist2,@"shouled have existed");
}

- (void)testRemoveExistingElementDisallowed {
  id item = [self generate];
  [_set removeItem:item];
  XCTAssertExceptionWithSubstring(@"!does not exist" ,^{[_set removeItem:item mustExist:YES];});
}

- (void)testLogarithmicComparisons {
    // DBG
    const float kConstantFactor = 1.9;
    
    NSUInteger pop = 2;
    while (pop < 100000) {
        [self populate:pop - [_set count]];
        int maxComp = (int) (pop * log(pop) * kConstantFactor);
        maxComp = MAX(maxComp,10);
        
        pr(@"pop %7d #comp %d max %d %@\n",pop,_numComparisons,maxComp,_numComparisons > maxComp ? @"!!!!!" : @"");
        
        XCTAssert(_numComparisons < maxComp,@"number of comparisons %d > expected maximum %d",_numComparisons,maxComp);
        
        pop *= 2;
    }
}

- (void)testCount {
    XCTAssert([_set count] == 0,@"should be zero");
    [self populate:100];
    XCTAssert([_set count] == 100,@"count mismatch");
}


- (void)testDeleteManyElements {
     //    DBG
    //    [IORecorder start];
    pr(@" populating...\n");
    [self populate:10000];
    pr(@" done populating\n");
    NSArray *a = [_generatedElements allObjects];
    NSData *data = [self.random permutation:[a count]];
    const int *p = [data bytes];
     //[self.random permutation:[a count]];
    _numComparisons = 0;
    
    for (int i = 0; i < [a count]; i++) {
        id item = [a objectAtIndex:p[i]];
        [_set removeItem:item mustExist:YES];
        if ((i+1)%1000 == 0) {
            pr(@" just deleted %@\n",item);
        }
    }
    
    pr(@"%d comparisons\n",_numComparisons );
//    free(p);
    XCTAssert([_set count] == 0,@"there are still %d elements in the set!",(int)[_set count]);
}

- (MySortedObject *)obj {
  MySortedObject *m = [[MySortedObject alloc] init];
  m.type = 0;
  m.value = [self.random randomInt:900 + 100];
  return m;
}

- (JSOrderedSet *)proxySet {
  return [JSOrderedSet setWithComparator:
   ^NSComparisonResult(MySortedObject *obj1, MySortedObject *obj2) {
    NSComparisonResult r;
       r = obj1.value - obj2.value;
      return r;
   }];
}

// Tests that a second object is found as an existing first one, if the
// comparator indicates they are equivalent
//
- (void)testSortProxy {
//  DBG
  
  JSOrderedSet *set = [self proxySet];
  int nObj = 10;
  MySortedObject *objs[nObj];
  for (int i = 0;i<nObj; i++) {
    objs[i] = [self obj];
    [set addItem:objs[i] mustNotExist:YES];
  }
  
  pr(@"Proxy set:\n%@\n",set);

  MySortedObject *o1 = objs[0];
  MySortedObject *o2 = [self obj];
  o2.type = 1;
  o2.value = -2;
  XCTAssert(![set containsItem:o2],@"shouldn't have found it");
  
  o2.value = o1.value;
  NSUInteger foundAt;
  BOOL found = [set containsItem:o2 index:&foundAt];
  XCTAssert(found && [set objectAtIndex:foundAt] == o1,@"expected to find %@",o1);
}

- (void)testPrecedingAndFollowingItems {
  int pop = 20;
  
  [self populate:pop];
  NSArray *ord = [self orderedElements];
  
  for (int i = 0; i < pop; i++) {
    id item = ord[i];
    id itemPExp = nil;
    id itemFExp = nil;
    if (i > 0)
      itemPExp = ord[i-1];
    if (i+1<pop)
      itemFExp = ord[i+1];
    
    NSUInteger pos = 0;
    BOOL found = [self.set itemPreceding:item index:&pos];
    BOOL expFound = (itemPExp != nil);
    
    XCTAssert(found == expFound,@"couldn't find item preceding #%d:%@",i,item);
    if (found && expFound) {
      id itemP = [self.set objectAtIndex:pos];
      XCTAssert(itemPExp == itemP,@"preceding item %@ not expected value %@",itemP,itemPExp);
    }
    
    pos = -1;
    found = [self.set itemFollowing:item index:&pos];
    expFound = (itemFExp != nil);
    
    XCTAssert(found == expFound,@"couldn't find item following #%d:%@",i,item);
    if (found && expFound) {
      id itemF = [self.set objectAtIndex:pos];
      XCTAssert(itemFExp == itemF,@"following item %@ not expected value %@",itemF,itemFExp);
    }
  }
}


@end



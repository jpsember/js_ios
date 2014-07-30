#import "JSTestUtil.h"

@interface NSOrderedSetTests : JSTestCase

@property (nonatomic, strong) NSMutableOrderedSet *set;
@property (nonatomic, strong) id comparator;
@property (nonatomic, assign) int numComparisons;
@property (nonatomic, strong) NSMutableSet *generatedElements;
@end


@implementation NSOrderedSetTests

- (void)setUp {
    [super setUp];
    NSOrderedSetTests *os = self;
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
    return s;
}

- (void)add:(NSString *)item {
    NSUInteger index = [_set indexOfObject:item inSortedRange:NSMakeRange(0,[_set count]) options:NSBinarySearchingInsertionIndex
                    usingComparator:_comparator];
    [_set insertObject:item atIndex:index];
}

- (void)populate:(int)count{
    [self populate:count set:_set];
}

- (void)populate:(int)count set:(NSMutableOrderedSet *)set {
    for (int i = 0; i < count; i++) {
        [self add:[self generate]];
    }
}

- (NSString *)show{
    return [self show:_set];
}

- (NSString *)show:(NSOrderedSet *)set {
    NSMutableString *s = [NSMutableString stringWithString:@"[ "];
    
    for (NSString *item in [set objectEnumerator]) {
        [s appendFormat:@"%@ ",item];
    }
    [s appendString:@"]"];
    return s;
}

- (void)testConstructor {
    XCTAssert([_set count] == 0,@"!");
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
    _set = [NSMutableOrderedSet orderedSet];
    _generatedElements = [NSMutableSet set];
}

//- (void)testLogarithmicComparisons {
//    // DBG
//    const float kConstantFactor = 1.7;
//    
//    int pop = 2;
//    while (pop < 100000) {
//        [self reset];
//        [self populate:pop];
//        int maxComp = (int) (pop * log(pop) * kConstantFactor);
//        
//        pr(@"pop %7d #comp %d max %d %@\n",pop,_numComparisons,maxComp,maxComp < _numComparisons ? @"!!!!!" : @"");
//        
//        pop *= 2;
//    }
//}

#if DEBUG
- (void)testDeleteElements {
    DBG
    [JSIORecorder start];
    [self populate:20];
    pr(@"%@\n",[self show]);
    NSArray *a = [_generatedElements allObjects];
    NSData *data = [self.random permutation:[a count]];
    const int *p = [data bytes];
    for (int i = 0; i < [a count]; i++) {
        id element = [a objectAtIndex:p[i]];
        pr(@"attempting to delete %@\n",element);
        [self.set removeObject:element];
        pr(@"%@\n",[self show]);
    }
    
    [JSIORecorder stop];
}
#endif

- (void)testDeleteElementsLarge2 {
    //    DBG
    //    [IORecorder start];
    pr(@" populating...\n");
    [self populate:100000];
    pr(@" done populating\n");
    NSArray *a = [_generatedElements allObjects];
    NSData *data = [self.random permutation:[a count]];
    const int *p = [data bytes];
    _numComparisons = 0;
    
    for (int i = 0; i < [a count]; i++) {
        id item = [a objectAtIndex:p[i]];
        NSUInteger index = [_set indexOfObject:item inSortedRange:NSMakeRange(0,[_set count]) options:NSBinarySearchingFirstEqual
                        usingComparator:_comparator];
        XCTAssert(index != NSNotFound);
        [self.set removeObjectAtIndex:index];
        
        if ((i+1)%1000 == 0) {
            pr(@" just deleted %@ from index %d\n",item,index);
        }
    }
    pr(@"%d comparisons\n",_numComparisons );
//    free(p);
    XCTAssert([_set count] == 0,@"there are still %d elements in the set!",(int)[_set count]);
    //    [IORecorder stop];
}



@end

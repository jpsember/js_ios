#if DEBUG

#import "JSTestUtil.h"
#import "JSMemoryMonitor.h"

typedef void(^BlockOperation)(void);

@interface MyTestObject : JSObject

@property (nonatomic, strong) NSMutableArray *blockOperations;

- (void)add;
+ (MyTestObject *)obj;
- (void)execute;

@end

@implementation MyTestObject

+ (MyTestObject *)obj {
  return [[MyTestObject alloc] init];
}

- (void)dealloc {
//  DBG
  pr(@"Destructing MyTestObject %p\n",self);
}

- (id)init {
  if (self = [super init]) {
//    DBG
    pr(@"Alloc MyTestObject %p\n",self);
  }
  return self;
}

- (void)_pushOper:(BlockOperation)oper {
  if (!_blockOperations)
    _blockOperations = [NSMutableArray array];
  [_blockOperations addObject:oper];
}

- (void)printSomething {
  [JSBase logString:@"buffered operation\n"];
}

- (void)add {
  __unsafe_unretained id _self = self;
  [self _pushOper:^{
    [_self printSomething];
  }];
}
- (void)execute {
  for (BlockOperation oper in _blockOperations) {
    oper();
  }
}


@end




@interface JSMemoryMonitorTests : JSTestCase

@property (nonatomic, strong) JSSwizzler *swizzler;

@end


@implementation JSMemoryMonitorTests

- (void)setUp {
  [super setUp];
  
  self.swizzler = [[JSSwizzler alloc] init];
  JSMemoryMonitor *ourMonitor = [[JSMemoryMonitor alloc] init];
  
  [self.swizzler add:[JSMemoryMonitor class] methodName:@"sharedInstance" body:^(id *_class){
    return ourMonitor;
  }];
}

- (void)testTooManyObjects
{
  [JSSharedMemoryMonitor setMaximumInstancesFor:[MyTestObject class] to:3];
  int i = 0;
  @try {
    NSMutableArray *a = [NSMutableArray array];
    for (i = 0; i < 5; i++) {
      pr(@"attempting to construct object #%d\n",i);
      [a addObject:[MyTestObject obj]];
    }
  } @catch (JSDieException *e) {
    XCTAssert(i == 3);
    XCTAssert([[e reason] containsString: @"Too many"]);
  }
}

- (void)testNotTooManyObjects
{
  int pop = 8;
  [JSSharedMemoryMonitor setMaximumInstancesFor:[MyTestObject class] to:pop];
  int i = 0;
  NSMutableArray *a = [NSMutableArray array];
  for (i = 0; i < pop; i++) {
    [a addObject:[MyTestObject obj]];
  }
}


- (void)testReducedCapacity
{
  [JSSharedMemoryMonitor setMaximumInstancesFor:[MyTestObject class] to:8];
  int i = 0;
  @try {
    NSMutableArray *a = [NSMutableArray array];
    for (i = 0; i < 8; i++) {
      pr(@"attempting to construct object #%d\n",i);
      [a addObject:[MyTestObject obj]];
      if (i == 5) {
        [JSSharedMemoryMonitor setMaximumInstancesFor:[MyTestObject class] to:4];
      }
    }
  } @catch (JSDieException *e) {
    XCTAssert(i == 5);
    XCTAssert([[e reason] containsString: @"Too many"]);
  }
}

- (void)testExpandedCapacity
{
  [JSSharedMemoryMonitor setMaximumInstancesFor:[MyTestObject class] to:6];
  int i = 0;
    NSMutableArray *a = [NSMutableArray array];
    for (i = 0; i < 8; i++) {
      pr(@"attempting to construct object #%d\n",i);
      [a addObject:[MyTestObject obj]];
      if (i == 5) {
        [JSSharedMemoryMonitor setMaximumInstancesFor:[MyTestObject class] to:8];
      }
    }
}

- (void)testDisplayObjectAllocationsAndDeallocations {
  [JSIORecorder start];
  [JSSharedMemoryMonitor setTraceFor:[MyTestObject class] to:YES];
  @autoreleasepool {
    DBG
    
    pr(@"Constructing test objects\n");
    
    NSMutableArray *arr = [NSMutableArray array];
    
    for (int i = 0; i < 10; i++) {
      [arr addObject:[MyTestObject obj]];
    }
    pr(@"Destroying test objects in random order\n");
    for (int i = 0; i < 10; i++) {
      [arr exchangeObjectAtIndex:i withObjectAtIndex:[self.random randomInt:10]];
    }
    for (int i = 0; i < arr.count; i++) {
      [arr removeObjectAtIndex:arr.count-1];
    }
    pr(@"Done test\n");
  }
  [JSSharedMemoryMonitor reset];
  [JSIORecorder stop];
}

- (void)testBlockRetainCycleProblems {
  [JSIORecorder start];
  [JSSharedMemoryMonitor setTraceFor:[MyTestObject class] to:YES];
  
   @autoreleasepool {
    MyTestObject *obj = [MyTestObject obj];
    
    [obj add];
    [obj add];
    [obj add];
    
    [obj execute];
  }
  [JSSharedMemoryMonitor setTraceFor:[MyTestObject class] to:NO];
  [JSIORecorder stop];
}

@end

#endif



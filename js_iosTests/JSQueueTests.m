#import "JSTestUtil.h"
#import "JSQueue.h"

@interface JSQueueTests : JSTestCase

@property (nonatomic, strong) JSQueue *queue;

@end


@implementation JSQueueTests

- (void)setUp {
    [super setUp];
  self.queue = [JSQueue queueWithArray:@[@"a",@"b",@"c",@"d",@"e"]];
}

- (void) tearDown {
    [super tearDown];
}

- (void)testConstructor {
    JSQueue *q = [JSQueue queue];
    XCTAssert([q isEmpty],@"!");
}

- (void)testFastEnumeratorFailsIfModifiedConcurrently {
  JSQueue *q = [JSQueue queue];
  for (int i = 0; i < 20; i++) {
    [q push:[NSString stringWithFormat:@"%c",'A'+i]];
  }
  for (int i = 0; i < 3; i++) {
    [q pop];
  }
  NSMutableArray *work = [NSMutableArray array];

  XCTAssertExceptionWithSubstring(@"was mutated",^{
  int rep = 0;
  for (id x in q) {
    rep++;
    if (rep == 7) {
      [q push:@"hey"];
    }
    [work addObject:x];
    
  }});
}

#if DEBUG
- (void)testWrap {
    [JSIORecorder start];
    DBG
    JSQueue *q = [JSQueue queue];
    [q push:@"A"];
    [q push:@"B"];
    [q push:@"C"];
    [q push:@"D"];
    [q push:@"E"];
    for (int i = 0; i < 100; i++) {
        id n = [q pop];
        [q push:n];
        pr(@"%@\n",q);
    }
    while (![q isEmpty]) {
        [q pop];
        pr(@"%@\n",q);
    }
    [JSIORecorder stop];
}

- (void)testGrow {
    [JSIORecorder start];
    DBG
    JSQueue *q = [JSQueue queue];
    for (int i = 0; i < 20; i++) {
        [q push:[NSString stringWithFormat:@"%c",'A'+i]];
        pr(@"%@\n",q);
    }
    while (![q isEmpty]) {
        [q pop];
        pr(@"%@\n",q);
    }
    [JSIORecorder stop];
}

- (void)testFastEnumerator {
  [JSIORecorder start];
  DBG
  JSQueue *q = [JSQueue queue];
  for (int i = 0; i < 20; i++) {
    [q push:[NSString stringWithFormat:@"%c",'A'+i]];
    pr(@"%@\n",q);
  }
  for (int i = 0; i < 3; i++) {
    [q pop];
  }
  pr(@"Beginning fast enumeration with:\n%@\n\n",q);
  for (id x in q) {
    pr(@"%@\n",x);
  }
  [JSIORecorder stop];
}



#endif

- (void)testPeek {
  int reps = 100;
  int maxSize = 70;
  
  JSQueue *q = [JSQueue queue];
  for (int i = 0; i < reps; i++) {
    [q push:@(i)];
    if (q.count > maxSize)
      [q pop];
  }
  for (int j = 0; j < maxSize; j++) {
    NSInteger v = [[q peekAtFront:YES distance:j] integerValue];
    XCTAssert(v == j + (reps - maxSize));
    v = [[q peekAtFront:NO distance:j] integerValue];
    XCTAssert(v == reps - 1 - j);
  }
}


#if DEBUG
- (void)testPushAndPop {
    int nIter = 120;
    [JSIORecorder start];
    DBG
    JSQueue *q = [JSQueue queue];
    for (int i = 0; i < nIter; i++) {
        pr(@" %3d: ",i);
        if (i < nIter/2) {
            if ([self randomInt:80] > 60) {
                if (![q isEmpty]) {
                    NSNumber *v = [q pop];
                    pr(@"popped %3d; %@\n",[v intValue],q);
                    continue;
                }
            }
            [q push:[NSNumber numberWithInt:i]];
            pr(@"pushed %3d; %@\n",i,q);
            
        } else {
            if ([q isEmpty]) {
                pr(@"queue empty, stopping\n");
                break;
            }
            NSNumber *v = [q pop];
            pr(@"popped %3d; %@\n",[v intValue],q);
        }
    }
    [JSIORecorder stop];
}

- (void)testPushAndPopRear {
    int nIter = 120;
    [JSIORecorder start];
    DBG
    JSQueue *q = [JSQueue queue];
    for (int i = 0; i < nIter; i++) {
        pr(@" %3d: ",i);
        if (i < nIter/2) {
            if ([self randomInt:80] > 60) {
                if (![q isEmpty]) {
                    NSNumber *v = [q pop:NO];
                    pr(@"popped %3d; %@\n",[v intValue],q);
                    continue;
                }
            }
            [q push:[NSNumber numberWithInt:i]];
            pr(@"pushed %3d; %@\n",i,q);
            
        } else {
            if ([q isEmpty]) {
                pr(@"queue empty, stopping\n");
                break;
            }
            NSNumber *v = [q pop:NO];
            pr(@"popped %3d; %@\n",[v intValue],q);
        }
    }
    [JSIORecorder stop];
}

- (void)testPushFrontAndPopRear {
    int nIter = 120;
    [JSIORecorder start];
    DBG
    JSQueue *q = [JSQueue queue];
    for (int i = 0; i < nIter; i++) {
        pr(@" %3d: ",i);
        if (i < nIter/2) {
            if ([self randomInt:80] > 60) {
                if (![q isEmpty]) {
                    NSNumber *v = [q pop:NO];
                    pr(@"popped %3d; %@\n",[v intValue],q);
                    continue;
                }
            }
            [q push:[NSNumber numberWithInt:i] toFront:YES];
            pr(@"pushed %3d; %@\n",i,q);
            
        } else {
            if ([q isEmpty]) {
                pr(@"queue empty, stopping\n");
                break;
            }
            NSNumber *v = [q pop:NO];
            pr(@"popped %3d; %@\n",[v intValue],q);
        }
    }
    [JSIORecorder stop];
}
#endif

- (void)testPopEmpty {
    JSQueue *q = [JSQueue queueWithArray:@[@"a",@"b",@"c",@"d"]];
    for (int i = 0; i < 4; i++)
        [q pop];
  XCTAssertExceptionWithSubstring(@"!pop of empty queue",^{[q pop];});
}

- (void)testPushToRearByDefault {
  JSQueue *q = self.queue;
  [q push:@"zz"];
  XCTAssertEqualObjects(@"zz",[q peekAtFront:NO]);
}

- (void)testPopFromFrontByDefault {
  JSQueue *q = self.queue;
  XCTAssertEqualObjects(@"a",[q pop]);
}

- (void)testPeekAtFrontByDefault {
  JSQueue *q = self.queue;
  XCTAssertEqualObjects(@"a",[q peek]);
}



@end



#import "JSTestUtil.h"
#import "JSPointerArray.h"

#define kNumberOfTestElements 80

#define kWorkStrings 5

static char * workStrings[] = {
  "alpha",
  "beta",
  "gamma",
  "delta",
  "epsilon",
};
static char * workStrings2[] = {
  "one",
  "two",
  "three",
  "four",
};


@interface JSPointerArrayTests : JSTestCase

@property (nonatomic, strong) JSPointerArray *buffer;
@property (nonatomic, strong) JSPointerArray *buffer2;
@property (nonatomic, assign) int nextStructNumber;
@property (nonatomic, assign) unsigned long ourMutationPointer;

@end

static char *truePointer(NSUInteger index) {
  return workStrings[index % kWorkStrings];
}

@implementation JSPointerArrayTests

- (void)setUp {
  [super setUp];
  self.ourMutationPointer = 0;
  
  _buffer = [JSPointerArray array];
  self.buffer2 = [JSPointerArray array];
  for (int i = 0; i < 4; i++) {
    [self.buffer2 push:workStrings2[i]];
  }
}

#if DEBUG
- (void)_dumpBuffer {
  DBG
  [JSIORecorder start];
  for (int i = 0; i < self.buffer.count; i++) {
    pr(@"%s\n",[self.buffer get:i]);
  }
  [JSIORecorder stop];
}

- (void)testAddObjectsFromArrayMiddle {
  for (int k = 0; k < 8; k++)
    [_buffer push:truePointer(k)];
  [self.buffer addObjectsFromArray:self.buffer2 sourceRange:NSMakeRange(1,3) destinationIndex:6];
  [self _dumpBuffer];
}

- (void)testAddObjectsFromArrayFront {
  for (int k = 0; k < 8; k++)
    [_buffer push:truePointer(k)];
  [self.buffer addObjectsFromArray:self.buffer2 sourceRange:NSMakeRange(1,3) destinationIndex:0];
  [self _dumpBuffer];
}

- (void)testAddObjectsFromArrayEnd {
  for (int k = 0; k < 8; k++)
    [_buffer push:truePointer(k)];
  [self.buffer addObjectsFromArray:self.buffer2 sourceRange:NSMakeRange(1,3) destinationIndex:self.buffer.count];
  [self _dumpBuffer];
}

- (void)testAddZeroObjectsFromArray {
  for (int k = 0; k < 8; k++)
    [_buffer push:truePointer(k)];
  [self.buffer addObjectsFromArray:self.buffer2 sourceRange:NSMakeRange(1,0) destinationIndex:3];
  [self _dumpBuffer];
}
#endif

- (void)testGrowing {
  for (int i = 0; i < 50; i++) {
    // Verify that there are i items
    int j = 0;
    enumeratePointers(_buffer) {
      char *sExp = truePointer(j);
      char *s = nextPointer();
      XCTAssert(s == sExp,@"s=%s, exp %s\n",s,sExp);
      j++;
    }
    XCTAssert(j == i);
    XCTAssert([_buffer count] == i);
    
    // Add another item
    [_buffer push:truePointer(_buffer.count)];
  }
}

- (void)_generateElements {
  for (int k = 0; k < kNumberOfTestElements; k++)
    [_buffer push:truePointer(k)];
}

- (void)testElementAccess {
  [self _generateElements];
  
  for (int i = 0; i < kNumberOfTestElements; i++) {
    char *s = [_buffer get:i];
    XCTAssert(s == truePointer(i));
  }
}

- (void)_testModifiedDuringEnumerationAux {
  int i = 0;
  
  enumeratePointers(_buffer) {
    nextPointer();
    i++;
    if (i == kNumberOfTestElements/2) {
      [_buffer push:truePointer(i)];
    }
  }
}

- (void)testModifiedDuringEnumeration {
  [self _generateElements];
  XCTAssertExceptionWithSubstring(@"was mutated while being enumerated",^{[self _testModifiedDuringEnumerationAux];});
}

@end
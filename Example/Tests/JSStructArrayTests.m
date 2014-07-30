#import "JSTestUtil.h"
#import "JSStructArray.h"

// Simple struct for test purposes
//
typedef struct {
  int x;
  int y;
  int z;
} OurStruct;

#define kNumberOfTestElements 80
#define kStructNumberBase 500

@interface JSStructArrayTests : XCTestCase

@property (nonatomic, strong) JSStructArray *buffer;
@property (nonatomic, assign) int nextStructNumber;
@property (nonatomic, assign) unsigned long ourMutationPointer;

@end

@implementation JSStructArrayTests

- (void)setUp {
//  printf(@"debug=%d\n",DEBUG);

  [super setUp];
  self.ourMutationPointer = 0;
  _buffer = [JSStructArray arrayWithStructSize:sizeof(OurStruct)];
}


// Initialize an OurStruct using the next unique number
- (void)initStruct:(OurStruct *)s {
  memset(s,0,sizeof(OurStruct));
  s->x = _nextStructNumber + kStructNumberBase;
  _nextStructNumber++;
}


- (void)testGrowing {
  for (int i = 0; i < 4; i++) {
    // Verify that there are i items
    int j = 0;
    enumerateStructs(_buffer) {
      OurStruct *s = nextPointer();
      XCTAssert(s->x == kStructNumberBase + j);
      j++;
    }
    XCTAssert(j == i);
    XCTAssert([_buffer count] == i);
    
    // Add another item
    OurStruct *s = [_buffer allocStruct];
    [self initStruct:s];
  }
}

- (void)generateElements {
  for (int i = 0; i < kNumberOfTestElements; i++) {
    OurStruct *s = [_buffer allocStruct];
    [self initStruct:s];
  }
}

- (void)testElementAccess {
  [self generateElements];
  
  for (int i = 0; i < kNumberOfTestElements; i++) {
    OurStruct *s = [_buffer get:i];
    XCTAssert(s->x == kStructNumberBase + i);
  }
}

- (void)_testModifiedDuringEnumerationAux {
  int i = 0;
  
  enumerateStructs(_buffer) {
    nextPointer();
    i++;
    if (i == kNumberOfTestElements/2) {
      [_buffer allocStruct];
    }
  }
}

- (void)testModifiedDuringEnumeration {
  [self generateElements];
  XCTAssertThrowsSpecificNamed([self _testModifiedDuringEnumerationAux],NSException,@"NSGenericException");
}


@end
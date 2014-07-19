#import "JSBase.h"
#import "JSStructArray.h"


@interface JSStructArray ()

// Redeclare properties as read/write
@property (nonatomic, assign, readwrite) NSUInteger count;
@property (nonatomic, assign, readwrite) NSUInteger elementSize;

@property (nonatomic, assign) unsigned long bufferSize;
@property (nonatomic, strong) NSMutableArray *buffers;
@property (nonatomic, strong) NSMutableData *currentBuffer;
@property (nonatomic, assign) unsigned long mutationCounter;
@property (nonatomic, assign) int elementsPerBuffer;

@end


@implementation JSStructArray

+ (JSStructArray *)arrayWithStructSize:(int)s {
  return [[self alloc] initWithElementSize:s];
}

- (id)initWithElementSize:(int)elementSize {
  if (self = [super init]) {
    _elementSize = elementSize;
    _elementsPerBuffer = MAX(4, 1024/elementSize);
    _bufferSize = _elementsPerBuffer * elementSize;
    
    [self clear];
  }
  return self;
}

- (void)clear {
  _count = 0;
  _buffers = [NSMutableArray array];
  _currentBuffer = nil;
  _mutationCounter++;
}

- (void)allocateBufferPage {
  NSMutableData *data = [NSMutableData dataWithCapacity:_bufferSize];
  [_buffers push:data];
  _currentBuffer = data;
}

- (void *)get:(NSUInteger)index {
  ASSERT(index < self.count,@"no such element %d in JSStructArray of size %d",(int)index,(int)self.count);
  
  NSUInteger bufferNumber = index / _elementsPerBuffer;
  NSUInteger bufferOffset = index % _elementsPerBuffer;
  
  return [_buffers[bufferNumber] mutableBytes] + (bufferOffset * _elementSize);
}

- (void *)allocStruct {
  _mutationCounter++;
  if (!_currentBuffer || [_currentBuffer length] == _bufferSize) {
    [self allocateBufferPage];
  }
  void *item = [_currentBuffer mutableBytes] + _currentBuffer.length;
  [_currentBuffer increaseLengthBy:_elementSize];
  _count++;
  return item;
}

- (void)resize:(NSUInteger)size {
  if (size < self.count) {
    self.count = size;
    _mutationCounter++;
  } else while (size > self.count) {
    [self allocStruct];
  }
}


typedef struct {
  unsigned long state;
  id __unsafe_unretained *itemsPtr;
  unsigned long *mutationsPtr;
  
  void *pointerIntoCurrentBuffer;
  long currentBufferBytesRemaining;
  long currentBufferIndex;
  
  unsigned long extra[2];
} OurFastEnumerationState;



- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state0 objects:(id __unsafe_unretained [])stackbuf count:(NSUInteger)len
{
//  DBG
  
  ASSERT(sizeof(NSFastEnumerationState) == sizeof(OurFastEnumerationState),0);
  
  OurFastEnumerationState *s = (OurFastEnumerationState *)state0;
  pr(@"countByEnumeratingWithState,  state=%d, stackbuf=%p\n",s->state,stackbuf);
  
  if (s->state == 0) {
    s->pointerIntoCurrentBuffer = NULL;
    s->currentBufferBytesRemaining = 0;
    s->currentBufferIndex = 0;
    s->mutationsPtr = &_mutationCounter;
  }
  
  NSUInteger batchCount = 0;
  while (batchCount < len) {
    pr(@" batchCount %d\n",batchCount);
    
    if (!s->currentBufferBytesRemaining) {
      pr(@"  opening next buffer; index=%d of %d\n",s->currentBufferIndex,[_buffers count]);
      if (s->currentBufferIndex < [_buffers count]) {
        NSMutableData *data = [_buffers objectAtIndex:s->currentBufferIndex];
        s->currentBufferIndex++;
        s->pointerIntoCurrentBuffer = [data mutableBytes];
        s->currentBufferBytesRemaining = [data length];
        pr(@"   bytes rem=%d\n",s->currentBufferBytesRemaining);
      }
      if (!s->currentBufferBytesRemaining) {
        pr(@"   no more bytes remain; breaking out\n");
        break;
      }
    }

    pr(@"pointer into current now %p\n",s->pointerIntoCurrentBuffer);
    
    void *structPtr = s->pointerIntoCurrentBuffer;
    
    stackbuf[batchCount] = (__bridge __unsafe_unretained id)(void *)structPtr;
    batchCount++;
    
    s->pointerIntoCurrentBuffer += _elementSize;
    s->currentBufferBytesRemaining -= _elementSize;
    pr(@" batchCount incr'd to %d, bufferBytesRem now %d\n",batchCount,s->currentBufferBytesRemaining);
  }
  s->state = 1;
  s->itemsPtr = stackbuf;
  s->mutationsPtr = &_mutationCounter;
  pr(@" returning batch count %d\n",batchCount);
  return batchCount;
}
@end


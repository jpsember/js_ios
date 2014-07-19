#import "JSBase.h"
#import "JSQueue.h"

@interface JSQueue()

//@property (nonatomic, assign, readwrite) NSUInteger count;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, assign) NSUInteger head;
@property (nonatomic, assign) NSUInteger tail;
@property (nonatomic, assign) unsigned long mutationCounter;

@end

@implementation JSQueue

+ (JSQueue *)queue {
  return [JSQueue queueWithCapacity:16];
}

+ (JSQueue *)queueWithArray:(NSArray *)array {
    JSQueue *q = [JSQueue queueWithCapacity:[array count]];
    for (id item in array) {
        [q push:item];
    }
    return q;
}

+ (JSQueue *)queueWithCapacity:(NSUInteger)capacity {
    return [[JSQueue alloc] initWithCapacity:capacity];
}

NO_DEFAULT_INITIALIZER

- (id)initWithCapacity:(NSUInteger)capacity {
    if (self = [super init]) {
        _array = [self _construct:1+capacity];
    }
    return self;
}

- (BOOL)isEmpty {
    return self.count == 0;
}

- (NSUInteger)count {
  NSUInteger n = _tail - _head;
  NSUInteger c = _array.count;
  if (n >= c)
    n += c;
  return n;
}

- (NSUInteger)_spaceRemaining {
    return [_array count] - self.count;
}

- (void)push:(id)item {
    [self push:item toFront:NO];
}

- (void)push:(id)item toFront:(BOOL)toFront {
  _mutationCounter++;
    if ([self _spaceRemaining] <= 1) {
        [self _expandBuffer];
    }
    if (!toFront) {
        [_array setObject:item atIndexedSubscript:_tail];
        _tail++;
        if (_tail == [_array count]) {
            _tail = 0;
        }
    } else {
      if (_head == 0)
        _head = _array.count;
      _head--;
      [_array setObject:item atIndexedSubscript:_head];
    }
}

- (id)peekAtFront:(BOOL)atFront {
  return [self peekAtFront:atFront distance:0];
}

- (id)peekAtFront:(BOOL)atFront distance:(NSUInteger)distance {
    NSUInteger count = self.count;
    if (distance >= count)
        die(@"queue range error");
    if (!atFront) {
        distance = count - 1 - distance;
    }
    return [_array objectAtIndex:[self _calcPos:distance]];
}

- (id)peek {
    return [self peekAtFront:YES];
}

- (id)pop:(BOOL)fromFront {
  _mutationCounter++;
  id ret;
    if (self.count == 0) {
        die(@"pop of empty queue");
    }
    if (!fromFront) {
        if (_tail-- == 0)
            _tail = [_array count] - 1;
        ret = [_array objectAtIndex:_tail];
        [_array setObject:[NSNull null] atIndexedSubscript:_tail];
    } else {
         ret = [_array objectAtIndex:_head];
          [_array setObject:[NSNull null] atIndexedSubscript:_head];
      if (++_head == [_array count])
            _head = 0;
    }
    return ret;
}

- (void)clear {
  _mutationCounter++;
  while (_head != _tail)
    [self pop];
}


- (id)pop {
    return [self pop:YES];
}

- (NSMutableArray *)_construct:(NSUInteger)capacity {
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:capacity];
    while (capacity-- > 0) {
        [a addObject:[NSNull null]];
    }
    return a;
}

- (NSString *)description {
    NSMutableString *sb = [NSMutableString stringWithString:@"["];
    for (int i = 0; i < self.count; i++) {
      id obj = [self peekAtFront:YES distance:i];
        [sb appendFormat:@" %@",obj];
    }
    [sb appendString:@" ]"];
    return sb;
}

- (void)_expandBuffer {
  NSMutableArray *a2 = [self _construct:[_array count] * 2];
  
  for (NSUInteger i = 0, j = _head; j != _tail; i++) {
    [a2 setObject:[_array objectAtIndex:j] atIndexedSubscript:i];
    if (++j == [_array count])
      j = 0;
  }
  _tail = self.count;
  _head = 0;
  _array = a2;
}

- (NSUInteger)_calcPos:(NSUInteger)fromStart {
    NSUInteger k = _head + fromStart;
    if (k >= [_array count])
        k -= [_array count];
    return k;
}

typedef struct {
  unsigned long state;
  id __unsafe_unretained *itemsPtr;
  unsigned long *mutationsPtr;
  unsigned long cursor;
  
  unsigned long extra[4];
} OurFastEnumerationState;


- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state0 objects:(id __unsafe_unretained [])stackbuf count:(NSUInteger)len
{
  //   DBG
  
  ASSERT(sizeof(NSFastEnumerationState) == sizeof(OurFastEnumerationState),0);
  
  OurFastEnumerationState *s = (OurFastEnumerationState *)state0;
  
  if (s->state == 0) {
    s->mutationsPtr = &_mutationCounter;
  }
  
  NSUInteger chunkSize = MIN(len,[self count] - s->cursor);
  
  for (NSUInteger i = 0; i < chunkSize; i++) {
    stackbuf[i] = [self peekAtFront:YES distance:i+s->cursor];
  }
  s->state = 1;
  s->itemsPtr = stackbuf;
  s->cursor += chunkSize;
  
  return chunkSize;
}

@end
#import "JSBase.h"
#import "JSPointerArray.h"

@interface JSPointerArray()

@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, assign) unsigned long mutationCounter;

@end

@implementation JSPointerArray

+ (JSPointerArray *)array {
    return [[JSPointerArray alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        _data = [NSMutableData data];
    }
    return self;
}

- (NSUInteger)count {
  return [_data length] / sizeof(void *);
}

- (void)clear {
  _mutationCounter++;
  [_data setLength:0];
}

- (void)push:(void *)ptr {
  _mutationCounter++;
    ASSERT(ptr,@"null ptr");
    [_data appendBytes:&ptr length:sizeof(void *)];
}

- (void *)pop {
    void *ptr = [self peek];
    [_data setLength:[_data length] - sizeof(void *)];
    return ptr;
}

- (BOOL)isEmpty {
    return [_data length] == 0;
}

- (void *)peek {
    return [self peek:0];
}

- (void *)peek:(NSUInteger)distanceFromTop {
  NSUInteger index = [self count] - 1 - distanceFromTop;
  ASSERT(index >= 0 && index < [self count],@"attempt to peek at distance %d, only %d elements",(int)distanceFromTop,(int)[self count]);
  return [self get:index];
}

- (void *)get:(NSUInteger)index {
  ASSERT(index >= 0 && index < self.count,@"illegal index %d (count=%d)",(int)index, (int)self.count);
  return *((void * const *)([_data bytes] +  index*sizeof(void*)));
}

- (void)set:(void *)ptr at:(NSUInteger)index {
  _mutationCounter++;
  ASSERT(index >= 0 && index < self.count,@"illegal index %d (count=%d)",(int)index, (int)self.count);
  *((void **)([_data mutableBytes] +  index*sizeof(void*))) = ptr;
}

- (void)insert:(void *)ptr at:(NSUInteger)index {
  _mutationCounter++;
  ASSERT(index >= 0 && index <= self.count,@"illegal index %d (count=%d)",(int)index, (int)self.count);
   [_data replaceBytesInRange:NSMakeRange(index*sizeof(void *),0) withBytes:&ptr length:sizeof(void *)];
}

- (void)remove:(NSUInteger)index {
  [self removeObjectsInRange:NSMakeRange(index,1)];
}

- (void)removeObjectsInRange:(NSRange)range {
  _mutationCounter++;
  NSUInteger remLength = range.length * sizeof(void*);
  [_data replaceBytesInRange:NSMakeRange(range.location*sizeof(void *),remLength) withBytes:NULL length:0];
}

- (void)addObjectsFromArray:(JSPointerArray *)src sourceRange:(NSRange)r destinationIndex:(NSUInteger)d {
  _mutationCounter++;
  NSUInteger sourceOffset = sizeof(void *) * r.location;
  NSUInteger destOffset = sizeof(void *) * d;
  NSUInteger bytesLength = sizeof(void *) * r.length;
  ASSERT(d <= self.count,@"illegal destination index %d (count=%d)",(int)d, (int)self.count);
  ASSERT(r.location + r.length <= src.count,@"illegal source range");
  
  _mutationCounter++;
  [_data replaceBytesInRange:NSMakeRange(destOffset,0)
                   withBytes:[[src data] bytes] + sourceOffset
                      length:bytesLength];
}

//- (void)remove:(NSUInteger)index count:(NSUInteger)count {
//  _mutationCounter++;
//  NSUInteger remLength = count * sizeof(void*);
//  [_data replaceBytesInRange:NSMakeRange(index*sizeof(void *),remLength) withBytes:NULL length:0];
//}

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
  pr(@"countByEnumeratingWithState,  state=%d, stackbuf=%p\n",s->state,stackbuf);
  
  if (s->state == 0) {
    s->mutationsPtr = &_mutationCounter;
  }
  
  NSUInteger chunkSize = MIN(len,[self count] - s->cursor);
  pr(@" cursor %d, count %d, len %d, chunkSize %d\n",s->cursor,self.count,len,chunkSize);
  
  void * const *ptrs = ((void * const *)([_data bytes] + s->cursor * sizeof(void*)));
  pr(@" data bytes=%p, ptrs=%p\n",[_data bytes],ptrs);
  
  for (NSUInteger i = 0; i < chunkSize; i++) {
    pr(@"  storing chunk element #%d: %p\n",i,ptrs[i]);
    stackbuf[i] = (__bridge __unsafe_unretained id)(ptrs[i]); //(void *)structPtr;
  }
  s->state = 1;
  s->itemsPtr = stackbuf;
  s->cursor += chunkSize;
  
  return chunkSize;
}

@end

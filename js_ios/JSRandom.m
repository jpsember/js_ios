#import "JSBase.h"
#import "JSRandom.h"

@interface JSRandom ()

@property (nonatomic, assign) int w;
@property (nonatomic, assign) int z;
#if DEBUG
@property (nonatomic, assign) int generationsSinceSeeded;
@property (nonatomic, assign) int seed;
#endif

@end

@implementation JSRandom

#if DEBUG

- (NSString *)description {
  return [NSString stringWithFormat:@"JSRandom %d:%d %x %x",self.seed,self.generationsSinceSeeded,self.w,self.z];
}
#endif

NO_DEFAULT_INITIALIZER

- (id)initWithSeed:(int)seed {
  if (self = [super init]) {
    if (seed == 0) {
      double unused;
      double fraction = modf(CACurrentMediaTime(),&unused);
      seed = (int)(fraction * 100000) + 1;
    }
#if DEBUG
    self.seed = seed;
    self.generationsSinceSeeded = 0;
#endif
    _w = seed;
    _z = seed;
    [self randomInt];
    [self randomInt];
  }
  return self;
}

+ (JSRandom *)randomWithSeed:(int)seed {
  return [[JSRandom alloc] initWithSeed:seed];
}


- (int)randomInt {
    _z = 36969 * (_z & 65535) + (_z >> 16);
    _w = 18000 * (_w & 65535) + (_w >> 16);
    int ret = ((_z << 16) + _w) & RAND_MAX;
#if DEBUG
//  DBG pr(@"Random (seed %d) returning %d:%x\n",self.seed,self.generationsSinceSeeded,ret);
  self.generationsSinceSeeded++;
#endif
    return ret;
}

- (int)randomInt:(NSUInteger)range {
    return [self randomInt] % range;
}

- (BOOL)randomBoolean {
    return ([self randomInt] & 1) ? YES : NO;
}

- (float)randomFloat:(float)range {
    float v = [self randomInt] * (range / (float)RAND_MAX);
    return v;
}

- (NSMutableData *)permutation:(NSUInteger)count {
    NSMutableData *data = [NSMutableData dataWithCapacity:sizeof(int)*count];
  
    if (data) {
        int *array = [data mutableBytes];
        for (int i = 0; i < count; i++) {
            array[i] = i;
        }
     
      for (NSUInteger i = count; i > 1; ) {
        int j = [self randomInt:i];
        i--;
        int temp = array[j];
        array[j] = array[i];
        array[i] = temp;
      }
    }
    return data;
}

@end

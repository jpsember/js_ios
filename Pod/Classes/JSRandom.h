// Seeded pseudorandom number generator, using algorithm described in
// http://en.wikipedia.org/wiki/Random_number_generation#Computational_methods
//

@interface JSRandom : NSObject

// Convenience constructor.
//
// Seed should be a positive integer, not equal to either 0x464fffff or 0x9068ffff;
// if zero, chooses seed derived from CACurrentMediaTime
//
+ (JSRandom *)randomWithSeed:(int)seed;

// Get random integer [0..RAND_MAX]
- (int)randomInt;
// Get random integer [0..range)
- (int)randomInt:(NSUInteger)range;
// Get random floating point value [0..range]
- (float)randomFloat:(float)range;
- (BOOL)randomBoolean;
// Calculate a random permutation of integers [0..count);
// returns nil if memory problem.
- (NSMutableData *)permutation:(NSUInteger)count;

#if DEBUG
// Some JSAlgorithmProtocol methods
- (void)encodeInput:(NSMutableString *)destination;
- (void)decodeInput:(NSScanner *)scanner;
#endif

@end

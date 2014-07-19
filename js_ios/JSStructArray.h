// Dynamic storage for C structs (or, more generally, fixed-length byte sequences).
// Once allocated, a struct is never moved, and hence pointers to it can be
// considered immutable.

@interface JSStructArray : NSObject<NSFastEnumeration>

@property (nonatomic, assign, readonly) NSUInteger count;
@property (nonatomic, assign, readonly) NSUInteger elementSize;

+ (JSStructArray *)arrayWithStructSize:(int)s;

- (id)initWithElementSize:(int)s;

- (void *)allocStruct;

- (void)clear;
- (void *)get:(NSUInteger)index;

// Adjust size of array; if size is increasing, allocates additional objects
- (void)resize:(NSUInteger)size;

@end

// Convenience macros to simplify fast enumeration over JSStructArrays.
// These are actually identical to their JSPointerArray counterparts.
//
// Example:
//
// 
//    JSStructArray *array = ...;
// 
//    enumerateStructs(array) {
//      JSVertex *v = nextPointer();
//      ... do something with v ...
//    }
//

#define enumerateStructs(__enumerable__) for (id __idObject__ in __enumerable__)
#ifndef nextPointer
#define nextPointer() (__bridge void *)__idObject__
#endif


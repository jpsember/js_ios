// A thin wrapper around NSMutableData to store an array of C-style pointers
//

@interface JSPointerArray : NSObject <NSFastEnumeration>

@property (nonatomic, assign, readonly) NSUInteger count;

+ (JSPointerArray *)array;
- (void)push:(void *)ptr;
- (void *)pop;
- (BOOL)isEmpty;
- (void *)peek;
- (void *)peek:(NSUInteger)distanceFromTop;
- (void)clear;
- (void *)get:(NSUInteger)index;
- (void)set:(void *)ptr at:(NSUInteger)index;
- (void)insert:(void *)ptr at:(NSUInteger)index;
- (void)remove:(NSUInteger)index;
- (void)removeObjectsInRange:(NSRange)range;
- (void)addObjectsFromArray:(JSPointerArray *)src sourceRange:(NSRange)r destinationIndex:(NSUInteger)d;

@end

// Convenience macros to simplify fast enumeration over JSPointerArrays
//
// Example:
//
//
//    JSPointerArray *array = ...;
//
//    enumeratePointers(array) {
//      JSVertex *v = arrayPointer();
//      ... do something with v ...
//    }
//

#define enumeratePointers(__enumerable__) for (id __idObject__ in __enumerable__)
#ifndef nextPointer
#define nextPointer() (__bridge void *)__idObject__
#endif

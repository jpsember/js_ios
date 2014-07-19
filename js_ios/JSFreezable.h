@protocol JSFreezable <NSCopying, NSMutableCopying>

@required

// Return true iff object is frozen
- (BOOL)frozen;

// Freeze object, if not already
- (void)freeze;

#if 0
// These methods are defined in the NSCopying, NSMutableCopying protocols:
@optional

// Get copy of self, with same frozen status as original.
// Returns self iff already frozen
- (id)copy;

// Get copy of self, one that is not frozen
- (id)mutableCopy;
#endif

@end

#if DEBUG

#define MUTABLE(__obj__) ASSERT(![__obj__ frozen],@"attempt to modify frozen object")

#else

#define MUTABLE(__obj__)

#endif

// Utility methods

// Get frozen copy of an object; returns original object if already frozen.
id frozenCopy(id<JSFreezable> original);

// Get a mutable copy of an object, if it's frozen; otherwise, return original (mutable) object.
id copyIfFrozen(id<JSFreezable> original);
  

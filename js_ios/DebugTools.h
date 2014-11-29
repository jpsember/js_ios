#if DEBUG
// Convenience methods to call swift methods from (Debug only) Objective-c code
#define dRect(rect) [DebugTools dRect:rect]
#define dPoint(point) [DebugTools dPoint:point]
#define dSize(cgsize) [DebugTools dSize:cgsize]
#define dDouble(value) [DebugTools dDouble:value format:nil]
#define dBool(value) [DebugTools dBoolean:value]
#define dBits(value) [DebugTools dBits:value]
#define dFloats(floats,len) [DebugTools dFloats:floats length:len]
#define dInts(ints,len) [DebugTools dInts:ints length:len]
#define dTransform(t) [DebugTools dTransform:t]
#define dImage(image) [DebugTools dImage:image]

#endif

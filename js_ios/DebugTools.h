#if DEBUG
// Convenience methods to call swift methods from (Debug only) Objective-c code
#define dRect(rect) [DebugTools dRect:rect]
#define dPoint(point) [DebugTools dPoint:point]
#define dDouble(value) [DebugTools dDouble:value format:nil]
#define dBool(value) [DebugTools dBoolean:value]
#endif

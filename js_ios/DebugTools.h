#if DEBUG
// Convenience methods to call swift methods from (Debug only) Objective-c code
#define dRect(rect) [DebugTools dRect:rect]
#define dPoint(point) [DebugTools dPoint:point]
#define dDouble(value) [DebugTools dDouble:value format:nil]
#define dBool(value) [DebugTools dBoolean:value]
#define dBits(value) [DebugTools dBits:((int)(value))]
#endif

@class UIImage;

@interface DebugTools : NSObject

+ (NSString *)dRect:(CGRect)rect;
+ (NSString *)dPoint:(CGPoint)point;
+ (NSString *)dDouble:(double)value;
+ (NSString *)dDouble:(double)value format:(NSString *)format;
+ (NSString *)dBoolean:(BOOL)value;
+ (NSString *)dFloats:(const CGFloat *)floats length:(int)length;
+ (NSString *)dBytes:(const byte *)bytes length:(int)length;
+ (NSString *)dImage:(UIImage *)image;
+ (NSString *)dBits:(int)value;

@end

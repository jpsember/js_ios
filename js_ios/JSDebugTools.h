#if DEBUG
// Convenience methods to call swift methods from (Debug only) Objective-c code
#define dRect(rect) [JSDebugTools dRect:rect]
#define dPoint(point) [JSDebugTools dPoint:point]
#define dDouble(value) [JSDebugTools dDouble:value format:nil]
#define dBool(value) [JSDebugTools dBoolean:value]
#define dBits(value) [JSDebugTools dBits:((int)(value))]
#endif

@class UIImage;

@interface JSDebugTools : NSObject

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

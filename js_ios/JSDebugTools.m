#import "js_ios-Swift.h"
#import "JSDebugTools.h"

@implementation JSDebugTools

// These methods are placed within a class, so they're accessible to objective c code

+ (NSString *)dPoint:(CGPoint)point {
  return [NSString stringWithFormat:@"(x:%@y:%@)",
          dDouble(point.x),dDouble(point.y)];
}


+ (NSString *)dRect:(CGRect)rect {
  return [NSString stringWithFormat:@"(x:%@y:%@w:%@h:%@)",
          dDouble(rect.origin.x),dDouble(rect.origin.y),dDouble(rect.size.width),dDouble(rect.size.height)];
}

+ (NSString *)dDouble:(double)value format:(NSString *)format {
	if (format == nil)
    format = @"%8.2f";
  return [NSString stringWithFormat:format, value];
}

+ (NSString *)dDouble:(double)value {
  return [JSDebugTools dDouble:value format:nil];
}

+ (NSString *)dBoolean:(BOOL)value {
  return value ? @"T" : @"F";
}

+ (NSString *)dFloats:(const CGFloat *)floats length:(int)length {
  NSMutableString *s = [NSMutableString string];
  for (int i = 0; i < length; i++) {
    [s appendString:dDouble(floats[i])];
    if ((i+1) % 4 == 0) {
      [s appendString:@"\n"];
    }
  }
  return s;
}

+ (NSString *)dBytes:(const byte *)bytes length:(int)length {
  NSMutableString *s = [NSMutableString string];
  for (int i = 0; i < length; i++) {
    [s appendFormat:@"%02x",bytes[i]];
    if ((i+1) % 4 == 0) {
      if ((i+1)%32 == 0) {
        [s appendString:@"\n"];
      } else {
      	[s appendString:@" "];
      }
    }
  }
  return s;
}

+ (NSString *)dImage:(UIImage *)image {
  CGImageRef ref = [image CGImage];
 CFDataRef data =  CGDataProviderCopyData(CGImageGetDataProvider(ref));
  const byte *pixels = CFDataGetBytePtr(data);
  int length = CFDataGetLength(data);
  int dumpedLength = MIN(length,32*4);
  return [NSString stringWithFormat:@"UIImage %d x %d:\n%@",(int)image.size.width,(int)image.size.height,[JSDebugTools dBytes:pixels length:dumpedLength]];
}

+ (NSString *)dBits:(int)value {
  NSMutableString *s = [NSMutableString string];
  BOOL bitPrinted = NO;
  for (int bitNumber = 32-1; bitNumber >=0 ; bitNumber--) {
    BOOL bit = (value & (1 << bitNumber)) != 0;
      if (bit || bitNumber == 4-1) {
        bitPrinted = YES;
      }
      if (bitPrinted) {
        [s appendString:bit?@"1":@"."];
        if (bitNumber != 0 && bitNumber % 4 == 0) {
          [s appendString:@" "];
        }
   	 }
  }
  return s;
}

@end

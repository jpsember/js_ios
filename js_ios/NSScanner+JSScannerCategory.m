#import "JSBase.h"
#import "NSScanner+JSScannerCategory.h"

#if DEBUG

@implementation NSScanner (JSScannerCategory)

- (void)toss:(NSString *)formatString, ... {
  va_list vl;
  va_start(vl, formatString);
  NSString *description = [[NSString alloc] initWithFormat:formatString arguments:vl];
  va_end(vl);

  NSString *disp;
  NSString *str = self.string;
  NSUInteger loc = self.scanLocation;
  int kDispLength = 80;
  if (loc > kDispLength) {
    disp = [NSString stringWithFormat:@"...%@(!)...",[str substringWithRange:NSMakeRange(loc-kDispLength,kDispLength)]];
  } else {
    disp = [NSString stringWithFormat:@"%@(!)...",[str substringToIndex:loc]];
  }
  die(@"Problem scanning (%@): %@",description,disp);
}

- (int)getInt {
  int result;
  if (![self scanInt:&result]) {
    [self toss:@"int"];
  }
  return result;
}

- (BOOL)getBool {
  if ([self scanString:@"Y" intoString:NULL]) return YES;
  [self getTag:@"N"];
  return NO;
}

- (double)getDouble {
  double result;
  if (![self scanDouble:&result]) {
    [self toss:@"double"];
  }
  return result;
}


- (int)getHex {
  unsigned hexVal;
  if (![self scanHexInt:&hexVal])
    [self toss:@"hex"];
  return hexVal;
}

- (void)getTag:(NSString *)tag {
  BOOL found = [self scanString:tag intoString:NULL];
  if (!found)
    [self toss:@"expected '%@'",tag];
}

@end

#endif

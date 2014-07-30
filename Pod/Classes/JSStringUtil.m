#import "JSBase.h"

@implementation NSString (JSStringUtil_NSStringCategory)

- (BOOL)endsWithWhitespace {
  return (self.length == 0 || [self characterAtIndex:self.length-1] <= ' ');
}

- (BOOL)containsString: (NSString*) substring
{
    NSRange range = [self rangeOfString : substring];
    BOOL found = ( range.location != NSNotFound );
    return found;
}

- (NSArray *)extractTokens {
  NSMutableArray *a = [NSMutableArray array];
  for (NSString *s in [self componentsSeparatedByString:@" "]) {
    if ([s length] > 0)
      [a addObject:s];
  }
  return a;
}

- (int) indexOf:(NSString *)substring mustExist:(BOOL)mustExist
{
    int index = -1;
    NSRange range = [self rangeOfString:substring];
    if (range.location != NSNotFound)
        index = (int)range.location;
    ASSERT(!(mustExist && index < 0),@"substring '%@' not found within '%@'",substring,self);
    return index;
}

- (int) indexOf:(NSString *)substring {
    return [self indexOf:substring mustExist:NO];
}

- (BOOL)writeToPath:(NSString *)path error:(NSError **)error {
  return [self writeToPath:path onlyIfChanged:NO error:error];
}

- (BOOL)writeToPath:(NSString *)path onlyIfChanged:(BOOL)onlyIfChanged error:(NSError **)error {
    NSFileManager *f = [NSFileManager defaultManager];
  if (onlyIfChanged && [f fileExistsAtPath:path] && [self isEqualToString:[NSString readFromPath:path error:error]])
        return YES;
    
    return [self writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:error];
}

- (NSString *)stringByReplacingPathExtensionWith:(NSString *)ext {
  return [[self stringByDeletingPathExtension] stringByAppendingPathExtension:ext];
}

+ (NSString *)readFromPath:(NSString *)p defaultContents:(NSString *)s error:(NSError **)error {
     NSFileManager *f = [NSFileManager defaultManager];
    if ([f fileExistsAtPath:p]) {
        return [NSString stringWithContentsOfFile:p encoding:NSUTF8StringEncoding error:error];
    }
    return s;
}

+ (NSString *)readFromPath:(NSString *)p error:(NSError **)error {
  return [NSString readFromPath:p defaultContents:nil error:error];
}

- (NSString *)trimWhitespace {
  NSUInteger left = 0;
  NSUInteger right = self.length;
  while (left < right && [self characterAtIndex:left] <= ' ')
    left++;
  while (right > left && [self characterAtIndex:right-1] <= ' ')
    right--;
  return [self substringWithRange:NSMakeRange(left,right-left)];
}

#if DEBUG
- (NSString *)objcString {
  NSMutableString *s = [NSMutableString string];
  int cursor = 0;
  do {
    int chunkSize = MIN((int)self.length - cursor, 80);
    // Look for place to break at the end of whitespace if possible
    if (chunkSize >= 10) {
      int seek = chunkSize;
      while (seek - 1 > (chunkSize * 3)/4) {
        if ([self characterAtIndex:cursor+seek-1] <= ' ') {
          chunkSize = seek;
          break;
        }
        seek--;
      }
    }
    [s appendString:@"@\""];
    NSString *p = [self substringWithRange:NSMakeRange(cursor,chunkSize)];
    for (int i = 0; i < p.length; i++) {
      NSString *sch;
      unichar ch = [p characterAtIndex:i];
      switch (ch) {
        case 0xa:
          sch = @"\\n";
          break;
          case ' ':
          sch = @" ";
          break;
        default:
        {
          if (ch >= 0x100) {
            sch = [NSString stringWithFormat:@"\\u%04x",ch];
          } else if (ch >= 0x80 || ch < ' ') {
            sch = [NSString stringWithFormat:@"\\x%02x",ch];
          } else {
            sch = [p substringWithRange:NSMakeRange(i,1)];
          }
        }
          break;
      }
      [s appendString:sch];
    }
    [s appendString:@"\"\n"];
    cursor += chunkSize;
  } while (cursor < self.length);
  return s;
}
#endif

@end

@implementation NSArray ( JSArrayCategory )

- (BOOL) isEmpty {
    return [self count] == 0;
}

@end


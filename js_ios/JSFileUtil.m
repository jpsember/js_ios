#include "JSBase.h"
#include "JSFileUtil.h"

@implementation NSFileManager (JSFileUtil_NSFileManagerCategory)

- (BOOL)removeAllItemsFromDirectory:(NSString *)path error:(NSError **)error {
  BOOL success = YES;
  NSDirectoryEnumerator *dirEnum = [self enumeratorAtPath:path];
  NSString *file;
  while ((file = [dirEnum nextObject])) {
    NSString *filePath = [path stringByAppendingPathComponent:file];
    BOOL success = [self removeItemAtPath:filePath error:error];
    if (!success) {
      break;
    }
  }
  return success;
}

@end
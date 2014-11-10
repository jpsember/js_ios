@implementation NSDictionary (JSDictionaryUtil_NSDictionaryCategory)

- (BOOL)containsKey:(id)key
{
    return [self objectForKey:key] != nil;
}

@end

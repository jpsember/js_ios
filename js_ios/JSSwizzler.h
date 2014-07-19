@interface JSSwizzler : NSObject

/*
 The name of exceptions thrown by the swizzle API
*/
+ (NSString *)exceptionName;

/*
 Technique #1 (preferred): provide the name of another method within the same class to 
 exchange method bodies with
 
 e.g., if you supply a category on NSFileManager with a method __swizzled__contentsEqualAtPath:andPath:,
 you can swizzle by calling
 
    [swizzler swap:[FileManager class] method1Name:"contentsEqualAtPath:andPath:" method2Name:"__swizzled__contentsEqualAtPath:andPath:"];
 
 or, since method2Name is "__swizzled__" + method1Name, by calling
 
    [swizzler swap:[FileManager class] methodName:"contentsEqualAtPath:andPath:"];
 
 I used to allow sending the name of a class, but using NSClassFromString produced a version of the class that
 sometimes omitted category methods.
*/
- (void)swap:(Class)theClass method1Name:(NSString *)m1 method2Name:(NSString *)m2;

/*
 Exchange method "XXX"'s body with method "__swizzled__XXX"'s body
*/
- (void)swap:(Class)theClass methodName:(NSString *)methodName;

/*
 Technique #2: provide a method body to replace the original's with
*/
- (void)add:(Class)theClass methodName:(NSString *)methodName body:(id)body;

/*
 Remove swizzle that was introduced 
*/
- (void)remove:(Class)theClass methodName:(NSString *)methodName;

- (void)removeAll;

#if DEBUG
+ (NSString *)getInstanceMethodsForClass:(Class)theClass;
#endif

@end

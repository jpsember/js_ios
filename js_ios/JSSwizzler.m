#import <objc/runtime.h>
#import "JSBase.h"
#import "JSSwizzler.h"


@interface SwizzledMethodEntry : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) Class theClass;
@property (nonatomic, strong) NSString *methodName;
@property (nonatomic, strong) NSString *method2Name;
@property (nonatomic, assign) BOOL isInstanceMethod;
@property (nonatomic, strong) NSString *originalMethodLocation;

@end

@implementation SwizzledMethodEntry

- (BOOL)isSwapMethod {
    return self.originalMethodLocation == nil;
}

#if DEBUG
- (NSString *)description {
    NSMutableString *s = [NSMutableString string];
    [s appendFormat:@"SwizzledMethodEntry key=%@ class=%p(%s) methodName=%@",
     self.key,self.theClass,class_getName(self.theClass),self.methodName];
    if (self.method2Name) {
        [s appendFormat:@" method2Name=%@",self.method2Name];
    }
    [s appendFormat:@" isInstance:%@ origLoc=%@",[JSBase stringFromBool:self.isInstanceMethod],self.originalMethodLocation];
    return s;
}
#endif

@end

@interface JSSwizzler()
@property NSMutableDictionary *entries;
@end

@implementation JSSwizzler

+ (NSString *)exceptionName
{
    return @"SwizzlerException";
}

- (instancetype)init
{
    if (self = [super init]) {
        _entries = nil;
        self.entries = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)swap:(Class)theClass method1Name:(NSString *)m1 method2Name:(NSString *)m2 {
    SwizzledMethodEntry *entry = [self _buildEntryFor:theClass methodName:m1];
    entry.method2Name = m2;
    [self _swapAux:entry restoring:NO];
}

- (void)swap:(Class)theClass methodName:(NSString *)m {
    [self swap:theClass method1Name:m method2Name:[[self class] _swizzledNameForMethod:m]];
}

- (void)add:(Class)theClass methodName:(NSString *)m body:(id)body {
    SwizzledMethodEntry *entry = [self _buildEntryFor:theClass methodName:m];
    entry.originalMethodLocation = [@"__swizzled_body_method__" stringByAppendingString:entry.methodName];
    SEL m1 = NSSelectorFromString(entry.methodName);
    entry.isInstanceMethod =  (NULL != class_getInstanceMethod(theClass,m1));
    
    if (!entry.isInstanceMethod) {
        theClass = object_getClass(theClass);
        if (!theClass)
            [[self class] _toss:@"no meta class found: %@" arg:entry.key];
    }
    
    IMP oldImplementation = class_getMethodImplementation(theClass,m1);
    
    Method meth1 = class_getInstanceMethod(theClass,m1);
    if (!meth1)
        [[self class] _toss:@"no method found: %@" arg:entry.methodName];
    
    const char *e1 = method_getTypeEncoding(meth1);
    
    IMP newImp = imp_implementationWithBlock(body);
    IMP oldImp USED_DEBUG_ONLY = class_replaceMethod(theClass,m1,newImp,e1);
    ASSERT(oldImp,@"no existing implementation found for class %s, method %@",class_getName(theClass),m);
  
    // Add method with swizzled name pointing to original implementation
    SEL m2 = NSSelectorFromString(entry.originalMethodLocation);
    
    // If an old method exists, it is from a previous swizzling
    Method methPrevious;
    if (!entry.isInstanceMethod) {
        methPrevious = class_getClassMethod(theClass,m2);
    } else {
        methPrevious = class_getInstanceMethod(theClass,m2);
    }
    if (!methPrevious) {
        class_addMethod(theClass, m2, oldImplementation, e1);
    } else {
        class_replaceMethod(theClass, m2, oldImplementation, e1);
    }
}

- (void)remove:(Class)theClass methodName:(NSString *)methodName
{
    [self _removeForKey:[[self class] _keyForClass:theClass methodName:methodName]];
}

- (void)removeAll
{
    for (NSString *key in [self.entries allKeys])
        [self _removeForKey:key];
}

+ _toss:(NSString *)message arg:(id)arg
{
    if (arg)
        message = [NSString stringWithFormat:message,arg];
    @throw [JSDieException exceptionWithMessage:message];
}

+ (NSString *)_swizzledNameForMethod:(NSString *)methodName
{
    return [NSString stringWithFormat:@"__swizzled__%@",methodName];
}

- (void)_swapAux:(SwizzledMethodEntry *)entry restoring:(BOOL)restoring {
    NSString *key = entry.key;
    
    Class theClass = entry.theClass;
    
    SEL sel1 = NSSelectorFromString(entry.methodName);
    SEL sel2 = NSSelectorFromString(entry.method2Name);
    
    if (!restoring) {
        BOOL instance = (NULL != class_getInstanceMethod(theClass,sel1));
        BOOL instance2 = (NULL != class_getInstanceMethod(theClass,sel2));
        if (instance != instance2) {
            [[self class] _toss:[NSString stringWithFormat:@"method signature mismatch: %@, %d vs %d",
                                 key,instance,instance2] arg:nil];
        }
        entry.isInstanceMethod = instance;
    }
    if (!entry.isInstanceMethod) {
        theClass  = object_getClass(theClass);
        if (!theClass)
            [[self class] _toss:@"no meta class found: %@" arg:key];
    }
    
    Method meth1 = class_getInstanceMethod(theClass,sel1);
    Method meth2 = class_getInstanceMethod(theClass,sel2);
    if (!restoring) {
        if (!meth1)
            [[self class] _toss:@"no method found: %@" arg:entry.methodName];
        if (!meth2)
            [[self class] _toss:@"no method found: %@" arg:entry.method2Name];
    }
    const char *e1 = method_getTypeEncoding(meth1);
    const char *e2 = method_getTypeEncoding(meth2);
    if (!restoring) {
        if (strcmp(e1,e2)) [[self class] _toss:@"method signature mismatch: %@" arg:key];
    }
    
    IMP implementation1 = class_getMethodImplementation(theClass,sel1);
    IMP implementation2 = class_getMethodImplementation(theClass,sel2);
    
    class_replaceMethod(theClass,sel1,implementation2,e1);
    class_replaceMethod(theClass,sel2,implementation1,e1);
}

- (SwizzledMethodEntry *)_buildEntryFor:(Class)theClass methodName:(NSString *)methodName {
    NSString *key = [[self class] _keyForClass:theClass methodName:methodName];
    
    if ([self.entries containsKey:key])
        [[self class] _toss:@"method already swizzled: %@" arg:key];
    
    SwizzledMethodEntry *entry = [[SwizzledMethodEntry alloc] init];
    entry.key = key;
    entry.theClass = theClass;
    entry.methodName = methodName;
    
    self.entries[entry.key] = entry;
    return entry;
}

+ (NSString *)_keyForClass:(Class)c methodName:(NSString *)m {
    return [NSString stringWithFormat:@"%s_%@",class_getName(c),m];
}

- (void)_removeForKey:(NSString *)key {
    if (![self.entries containsKey:key])
        [[self class] _toss:@"method wasn't swizzled: %@" arg:key];
    SwizzledMethodEntry *entry = self.entries[key];
    [self.entries removeObjectForKey:key];

    if ([entry isSwapMethod]) {
        [self _swapAux:entry restoring:YES];
        return;
    }
    
    SEL m1 = NSSelectorFromString(entry.methodName);
    SEL m2 = NSSelectorFromString(entry.originalMethodLocation);
    Class theClass = entry.theClass;
    if (!entry.isInstanceMethod) {
        theClass = object_getClass(theClass);
        if (!theClass)
            [[self class] _toss:@"no superclass found: %@" arg:key];
    }
    
    IMP originalImplementation = class_getMethodImplementation(theClass,m2);
    
    Method meth1;
    if (!entry.isInstanceMethod) {
        meth1 = class_getClassMethod(theClass,m1);
    } else {
        meth1 = class_getInstanceMethod(theClass,m1);
    }
    
    const char *e1 = method_getTypeEncoding(meth1);
    
    // Remove the block that was stored with the swizzled implementation (to prevent memory leaks)
    IMP swizzledImplementation = class_getMethodImplementation(theClass,m1);
    ASSERT(swizzledImplementation,nil);
    imp_removeBlock(swizzledImplementation);
    
    class_replaceMethod(theClass,m1,originalImplementation,e1);
}

#if DEBUG
+ (NSString *)getInstanceMethodsForClass:(Class)theClass {
    uint outCount;
    Method *methods = class_copyMethodList(theClass,&outCount);
    NSMutableString *s = [NSMutableString stringWithFormat:@"Instance methods for class %s:\n",class_getName(theClass)];
    for (uint i = 0; i < outCount; i++) {
        [s appendFormat:@" %s\n",sel_getName(method_getName(methods[i]))];
    }
    free(methods);
    return s;
}
#endif

@end

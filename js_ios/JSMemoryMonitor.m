#if DEBUG

#import "JSBase.h"
#import "JSMemoryMonitor.h"
#import "JSSymbolicNames.h"
#import "JSStackTraceElement.h"


@class JSObjectInstanceRecord;

// This internal class is used for instances whose destruction triggers bookkeeping events within the manager

@interface JSRemovalTrigger : NSObject

@property (nonatomic, strong) JSObjectInstanceRecord *instance;
@property (nonatomic, strong) JSMemoryMonitor *monitor;

- (id)initWithInstanceRecord:(JSObjectInstanceRecord *)instance monitor:(JSMemoryMonitor *)monitor;
- (void)reportDestructionToMonitor;

@end

@implementation JSObject

- (id)init {
  if (self = [super init]) {
    _memoryMonitorObject = [[JSMemoryMonitor sharedInstance] objectConstructed:self];
//    DBG
    pr(@"JSObject %p constructed, trigger %@\n",self,_memoryMonitorObject);
  }
  return self;
}

// This shouldn't be necessary; but for some reason, the monitor object's dealloc method
// is not being called promptly after this dealloc method completes.  So, we will
// explicitly ask it to inform the monitor of this object's destruction.
- (void)dealloc {
//  DBG
  pr(@"JSObject %p destructed, trigger %@\n",self,_memoryMonitorObject);
  JSRemovalTrigger *trigger = _memoryMonitorObject;
  [trigger reportDestructionToMonitor];
}

@end


// This internal class records individual instances of a class within the manager

@interface JSObjectInstanceRecord : NSObject

@property (nonatomic, assign) int instanceNumber;
@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSArray *stackTrace;
@property (nonatomic, assign) void *ptr;

@end

@implementation JSObjectInstanceRecord

+ (JSObjectInstanceRecord *)recordWithInstanceNumber:(int)n className:(NSString *)className pointer:(void *)ptr {
  JSObjectInstanceRecord *r = [[JSObjectInstanceRecord alloc] init];
  r.instanceNumber = n;
  r.className = className;
  r.ptr = ptr;
  return r;
}

- (NSString *)description {
  NSMutableString *str =  [NSMutableString string];
  [str appendFormat:@"#%d",_instanceNumber];
  if (_stackTrace) {
    [str appendString:@":    "];
    NSUInteger k = str.length;
    for (JSStackTraceElement *elem in _stackTrace) {
      while (str.length < k)
        [str appendString:@" "];
      
      [str appendString:[elem description]];
      [str appendString:@" "];
      k+= 40;
    }
  } else {
    [str appendString:@" (stack traces are not enabled)"];
  }
  return str;
}

@end



// This internal class records all instances of a particular class

@interface JSObjectClassRecord : NSObject

@property (nonatomic, strong) NSString *className;
@property (nonatomic, assign) int maxInstances;
@property (nonatomic, strong) NSMutableDictionary *instanceMap;
@property (nonatomic, assign, readonly) BOOL atCapacity;
@property (nonatomic, assign) BOOL tracing;

- (JSObjectInstanceRecord *)getInstance:(NSString *)symbolicName;
- (void)addInstance:(JSObjectInstanceRecord *)rec;
- (void)removeInstance:(JSObjectInstanceRecord *)rec;
- (BOOL)changeMaxInstances:(int)maxInstances;

@end


@implementation JSObjectClassRecord

- (id)init:(NSString *)className {
  if (self = [super init]) {
    _className = className;
    _maxInstances = -1;
    _instanceMap = [NSMutableDictionary dictionary];
  }
  return self;
}

- (BOOL)changeMaxInstances:(int)maxInstances {
  if (_maxInstances >= 0 && _instanceMap.count > maxInstances) {
    return NO;
  }
  _maxInstances = maxInstances;
  return YES;
}


- (BOOL)atCapacity {
  return _maxInstances >= 0 && _instanceMap.count >= _maxInstances;
}

- (JSObjectInstanceRecord *)getInstance:(NSString *)symbolicName {
  return _instanceMap[symbolicName];
}

- (void)addInstance:(JSObjectInstanceRecord *)rec {
  if (_tracing) {
    DBG
    pr(@"Constructing %@: %@\n",_className,rec);
  }
  _instanceMap[@(rec.instanceNumber)] = rec;
}

- (void)removeInstance:(JSObjectInstanceRecord *)rec {
//  DBG
  pr(@"JSObjectClassRecord %@, remove instance %@ \n",_className,rec);
  [_instanceMap removeObjectForKey:@(rec.instanceNumber)];
  
  if (_tracing) {
    DBG
    pr(@"Destructing %@: %@\n",_className,rec);
  }
}

- (NSString *)description {
  NSMutableString *str = [NSMutableString stringWithFormat:@"'%@' (max instances %d):\n",_className,_maxInstances];
#if 0
  for (JSObjectInstanceRecord *r in [_instanceMap allValues]) {
    [str appendFormat:@"%@]\n",r];
  }
#endif
  return str;
}

@end






@interface JSMemoryMonitor ()

@property (nonatomic, strong) NSMutableDictionary *objectSets;
@property (nonatomic, strong) NSMutableDictionary *globalInstanceMap;
@property (nonatomic, assign) int uniqueIndex;
@property (nonatomic, assign) int instanceNumber;

- (int)getNewInstanceNumber;
- (void)objectDestroyed:(int)instanceNumber;

@end


@implementation JSMemoryMonitor

+ (NSString *)exceptionName {
  return @"JSMemoryMonitorException";
}

- (int)getNewInstanceNumber {
  return _instanceNumber++;
}

+ (JSMemoryMonitor *)sharedInstance {
  static JSMemoryMonitor *instance;
  ONCE_ONLY(^{
    instance = [[JSMemoryMonitor alloc] init];
  });
  return instance;
}

- (id)init {
  if (self = [super init]) {
    _objectSets = [NSMutableDictionary dictionary];
    _globalInstanceMap = [NSMutableDictionary dictionary];
    _uniqueIndex = 100;
    if ([JSBase testModeActive]) {
      _stackTracesEnabled = YES;
    }
  }
  return self;
}

- (void)reset {
  @synchronized(self) {
    [_objectSets removeAllObjects];
    [_globalInstanceMap removeAllObjects];
    _uniqueIndex = 100;
  }
}

- (void)setMaximumInstancesFor:(Class)theClass to:(int)m {
  @synchronized(self) {
    JSObjectClassRecord *classRecord = [self _classRecordFor:theClass];
    if (![classRecord changeMaxInstances:m]) {
      [self _toss:@"Too many objects in class:\n%@",classRecord];
    }
  }
}

// Retrieve the JSObjectClassRecord for a class, constructing one if necessary
//
- (JSObjectClassRecord *)_classRecordFor:(Class)theClass {
  NSString *type = NSStringFromClass(theClass);
  JSObjectClassRecord *classRecord = _objectSets[type];
  if (!classRecord) {
    classRecord = [[JSObjectClassRecord alloc] init:type];
    _objectSets[type] = classRecord;
  }
  return classRecord;
}

- (void)setTraceFor:(Class)theClass to:(BOOL)status {
  @synchronized(self) {
    JSObjectClassRecord *classRecord = [self _classRecordFor:theClass];
    classRecord.tracing = status;
  }
}

- (id)objectConstructed:(id)object {
  //DBG
  
  @synchronized(self) {
    JSObjectClassRecord *classRecord = [self _classRecordFor:[object class]];

    JSObjectInstanceRecord *record = [JSObjectInstanceRecord recordWithInstanceNumber:[self getNewInstanceNumber]
                                                                            className:classRecord.className
                                                                              pointer:(__bridge void *)object];

    if (_stackTracesEnabled) {
      NSMutableArray *stackTrace = [JSBase stackTrace];
      
      int trim = 3;
      int retain = 3;
      NSArray *a = [stackTrace subarrayWithRange:NSMakeRange(trim,MIN(stackTrace.count-trim,retain))];
      record.stackTrace = a;
    }
    
    if ([_globalInstanceMap containsKey:@(record.instanceNumber)]) {
      [self _toss:@"Object with pointer already exists: %@",_globalInstanceMap[@(record.instanceNumber)]];
    }
    
    if (classRecord.atCapacity) {
      [self _toss:@"Too many objects in class:\n%@",classRecord];
    }
    
    _globalInstanceMap[@(record.instanceNumber)] = record;
    [classRecord addInstance:record];
    pr(@"Object constructed, classRecord %@\n",classRecord);
    
    // Construct an object whose destructor will trigger the removal of the object from the memory monitor.
    id trigger = [[JSRemovalTrigger alloc] initWithInstanceRecord:record monitor:self];
    
    //pr(@" returning trigger %@\n",dp(trigger));
    return trigger;
  }
}

- (void)objectDestroyed:(int)instanceNumber {
  @synchronized(self) {
//    DBG
//      NSString *symbolicName = [_symbolicNames nameForId:object];
    pr(@"JSMemoryMonitor.objectDestroyed %d\n",instanceNumber);
    
      JSObjectInstanceRecord *record = _globalInstanceMap[@(instanceNumber)];
      if (!record) {
        [self _toss:@"Object is not in map: %d",instanceNumber];
      }
      pr(@" removing object %p from global map with instance number %d\n",record.ptr,record.instanceNumber);
    
      JSObjectClassRecord *classRecord = _objectSets[record.className];
    pr(@" classRecord %@\n",classRecord);
      ASSERT(classRecord,@"no class record found");
      [classRecord removeInstance:record];
    [_globalInstanceMap removeObjectForKey:@(instanceNumber)];
  }
}

- (void)_toss:(NSString *)format,... {
  [JSBase flushLog];
  va_list vl;
  va_start(vl, format);
  NSString *s = [[NSString alloc] initWithFormat:format arguments:vl];
  va_end(vl);
  @throw [JSDieException exceptionWithMessage:s];
}

@end


@implementation JSRemovalTrigger

- (id)initWithInstanceRecord:(JSObjectInstanceRecord *)instance monitor:(JSMemoryMonitor *)monitor {
  if (self = [super init]) {
    _instance = instance;
    _monitor = monitor;
   // DBG
    pr(@"alloc trigger %p, instance number %@\n",self,_instance.instanceNumber);
  }
  return self;
}

- (void)dealloc {
//  DBG
  pr(@"dealloc trigger %p, instance number %d\n",self,_instance.instanceNumber);
  [self reportDestructionToMonitor];
}

- (void)reportDestructionToMonitor {
     [_monitor objectDestroyed:_instance.instanceNumber];
    _monitor = nil;
  
}


@end


#endif

#import <GLKit/GLKit.h>

#if DEBUG
#define dTransform4(t) [GLTools dumpTransform:t]
#endif

@class Texture;

@interface GLTools : NSObject

+ (NSString *)dumpBuffer;
+ (void)addIdToTextureDeleteList:(GLuint)textureId;
+ (void)flushTextureDeleteList;

@end


#import <GLKit/GLKit.h>

@class Texture;

@interface TextureTools : NSObject

+ (NSString *)dumpBuffer;
+ (void)addIdToDeleteList:(GLuint)textureId;
+ (void)flushDeleteList;

@end


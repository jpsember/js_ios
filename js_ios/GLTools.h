#import <GLKit/GLKit.h>

#if DEBUG
#define dTransform4(t) [GLTools dumpTransform:t]
#endif

@class Texture;

@interface GLTools : NSObject

+ (void)setGLColor:(UIColor *)uiColor;
+ (void)setGLColor:(UIColor *)uiColor destination:(GLfloat *)dest;
+ (NSString *)dumpBuffer;
+ (void)addIdToTextureDeleteList:(GLuint)textureId;
+ (void)flushTextureDeleteList;

@end


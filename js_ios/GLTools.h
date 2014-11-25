#import <GLKit/GLKit.h>

@class Texture;

@interface GLTools : NSObject

+ (void)setGLColor:(UIColor *)uiColor;
+ (void)setGLColor:(UIColor *)uiColor destination:(GLfloat *)dest;
+ (NSString *)dumpBuffer;
+ (void)addIdToTextureDeleteList:(GLuint)textureId;
+ (void)flushTextureDeleteList;

@end


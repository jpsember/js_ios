@interface GLBuffer : NSObject

@property (nonatomic, assign, readonly) CGPoint size;
@property (nonatomic, assign, readonly) GLuint textureId;
@property (nonatomic, assign, readonly) BOOL hasAlpha;

+ (GLBuffer *)bufferWithSize:(CGPoint)size hasAlpha:(BOOL)hasAlpha;

- (void)openRender;
- (void)closeRender;

@end

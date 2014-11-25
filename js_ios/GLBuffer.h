@interface GLBuffer : NSObject

@property (nonatomic, assign, readonly) CGPoint size;
@property (nonatomic, strong, readonly) Texture *texture;
@property (nonatomic, assign, readonly) BOOL hasAlpha;

+ (GLBuffer *)bufferWithSize:(CGPoint)size hasAlpha:(BOOL)hasAlpha;

- (void)openRender;
- (void)closeRender;

@end

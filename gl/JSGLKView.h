#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface JSGLKView : GLKView

+ (JSGLKView *)viewWithFrame:(CGRect)bounds;

- (id) initWithFrame:(CGRect)bounds;

@end
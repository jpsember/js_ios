#import "JSGLKView.h"

@implementation JSGLKView {
}

+ (JSGLKView *)viewWithFrame:(CGRect)bounds {
    JSGLKView *view = [[JSGLKView alloc] initWithFrame:bounds];
    return view;
}

- (id)initWithFrame:(CGRect)bounds {
    self = [super initWithFrame:bounds];
    if (self) {
        EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        self.context = context;
    }
    return (self);
}

@end

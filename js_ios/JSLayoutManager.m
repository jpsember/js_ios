#import "JSLayoutManager.h"

@interface JSLayoutManager()
@property (nonatomic, strong) UIView *parentView;
@end

@implementation JSLayoutManager


+ (JSLayoutManager *)managerForView:(UIView *)parentView {
    JSLayoutManager *m = [[JSLayoutManager alloc] init];
    m.parentView = parentView;
    return m;
}


- (void)matchLeft:(UIView *)childView in:(UIView *)view2 padding:(int)padding {
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:childView
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:view2
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1
                                                          constant:padding];
    [_parentView addConstraint:c];
}

- (void)matchLeft:(UIView *)childView in:(UIView *)view2 {
    [self matchLeft:childView in:view2  padding:0];
}
- (void)matchRight:(UIView *)childView in:(UIView *)view2 padding:(int)padding {
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:childView
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:view2
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1
                                                          constant:-padding];
    [_parentView addConstraint:c];
}
- (void)matchRight:(UIView *)childView in:(UIView *)view2 {
    [self matchRight:childView in:view2  padding:0];
}

- (void)matchTop:(UIView *)childView in:(UIView *)view2 padding:(int)padding {
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:childView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:view2
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1
                                                          constant:padding];
    [_parentView addConstraint:c];
}
- (void)matchTop:(UIView *)childView in:(UIView *)view2 {
    [self matchTop:childView in:view2  padding:0];
}
- (void)matchBottom:(UIView *)childView in:(UIView *)view2 padding:(int)padding {
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:childView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:view2
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1
                                                          constant:-padding];
    [_parentView addConstraint:c];
}
- (void)matchBottom:(UIView *)childView in:(UIView *)view2 {
    [self matchBottom:childView in:view2  padding:0];
}


- (void)joinVert:(UIView *)vAbove  to:(UIView *)vBelow padding:(int)padding {
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:vAbove
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vBelow
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1
                                                          constant:-padding];
    [_parentView addConstraint:c];
}

- (void)joinHorz:(UIView *)vLeft  to:(UIView *)vRight padding:(int)padding {
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:vLeft
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vRight
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1
                                                          constant:-padding];
    [_parentView addConstraint:c];
}

- (void)joinVert:(UIView *)vAbove  to:(UIView *)vBelow {
    [self joinVert:vAbove to:vBelow padding:0];
}

- (void)joinHorz:(UIView *)vLeft  to:(UIView *)vRight {
    [self joinHorz:vLeft to:vRight padding:0];
}

- (void)setHeight:(UIView *)view to:(int)height {
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:0
                                                          constant:height];
    [_parentView addConstraint:c];
}
- (void)setMinHeight:(UIView *)view to:(int)height {
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:0
                                                          constant:height];
    [_parentView addConstraint:c];
}
- (void)setMaxHeight:(UIView *)view to:(int)height {
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:0
                                                          constant:height];
    [_parentView addConstraint:c];
}

- (void)setWidth:(UIView *)view to:(int)height {
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:0
                                                          constant:height];
    [_parentView addConstraint:c];
}
- (void)setMinWidth:(UIView *)view to:(int)height {
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:0
                                                          constant:height];
    [_parentView addConstraint:c];
}
- (void)setMaxWidth:(UIView *)view to:(int)height {
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:0
                                                          constant:height];
    [_parentView addConstraint:c];
}

@end

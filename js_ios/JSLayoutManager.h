@interface JSLayoutManager : NSObject

+ (JSLayoutManager *)managerForView:(UIView *)parentView;

- (void)matchLeft:(UIView *)view1 in:(UIView *)view2 padding:(int)padding;
- (void)matchLeft:(UIView *)view1 in:(UIView *)view2;
- (void)matchRight:(UIView *)view1 in:(UIView *)view2 padding:(int)padding;
- (void)matchRight:(UIView *)view1 in:(UIView *)view2;
- (void)matchTop:(UIView *)view1 in:(UIView *)view2;
- (void)matchBottom:(UIView *)view1 in:(UIView *)view2 padding:(int)padding;
- (void)matchBottom:(UIView *)view1 in:(UIView *)view2;
- (void)joinVert:(UIView *)vAbove to:(UIView *)vBelow padding:(int)padding;
- (void)joinHorz:(UIView *)vLeft to:(UIView *)vRight padding:(int)padding;
- (void)joinVert:(UIView *)vAbove to:(UIView *)vBelow;
- (void)joinHorz:(UIView *)vLeft to:(UIView *)vRight;
- (void)setHeight:(UIView *)view to:(int)height;
- (void)setMinHeight:(UIView *)view to:(int)height;
- (void)setMaxHeight:(UIView *)view to:(int)height;
- (void)setWidth:(UIView *)view to:(int)height;
- (void)setMinWidth:(UIView *)view to:(int)height;
- (void)setMaxWidth:(UIView *)view to:(int)height;

@end

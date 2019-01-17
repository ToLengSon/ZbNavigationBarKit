//
//  UIView+ZbNavigationBarKit.h
//  ZbNavigationBarKit
//
//  Created by wsong on 2019/1/15.
//

#import <UIKit/UIKit.h>

@interface UIView (ZbNavigationBarKit)


#pragma mark - Property -- 属性声明
/** didAddSubview与bringSubviewToFront回调 */
@property (nonatomic, copy) void (^zb_didAddSubviewHandler)(UIView *subview);

#pragma mark - Function -- 方法
/**
 截图

 @return 获取当前视图的截图
 */
- (UIView *)zb_snap;


@end

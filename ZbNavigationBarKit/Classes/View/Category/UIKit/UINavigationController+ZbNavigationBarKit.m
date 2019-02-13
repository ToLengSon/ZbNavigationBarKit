//
//  UINavigationController+ZbNavigationBarKit.m
//  ZbNavigationBarKit
//
//  Created by wsong on 2019/1/14.
//

#import "ZbNavigationBarKit.h"
#import "UINavigationController+ZbNavigationBarKit.h"
#import "UIView+ZbNavigationBarKit.h"
#import <objc/runtime.h>
#import "Masonry.h"

#pragma mark - Define&StaticVar -- 静态变量和Define声明

@interface UINavigationController ()
<UIGestureRecognizerDelegate>

/** 导航栏过渡动画容器 */
@property (nonatomic, strong) UIView *zb_transitionContainerView;
/** 上一个导航栏 */
@property (nonatomic, weak) ZbNavigationBar *zb_preNavigationBarView;
/** 当前导航栏 */
@property (nonatomic, weak) ZbNavigationBar *zb_currentNavigationBarView;
/** 上一个导航栏截图 */
@property (nonatomic, strong) UIView *zb_preNavigationBarSnapView;
/** 当前导航栏截图 */
@property (nonatomic, strong) UIView *zb_currentNavigationBarSnapView;
/** 标识是否开始过渡 */
@property (nonatomic, assign, getter=zb_isBeginTransition) BOOL zb_beginTransition;

/**
 即将隐藏的控制器

 @return 即将隐藏的控制器
 */
- (UIViewController *)disappearingViewController;

@end


@implementation UINavigationController (ZbNavigationBarKit)

#pragma mark - Getter&Setter -- 懒加载
/** 导航栏过渡动画容器 */
- (UIView *)zb_transitionContainerView {
    if (!objc_getAssociatedObject(self, _cmd)) {
        UIView *transitionContainerView = [[UIView alloc] init];
        transitionContainerView.userInteractionEnabled = NO;
        transitionContainerView.backgroundColor = [UIColor clearColor];
        transitionContainerView.clipsToBounds = YES;
        [self.view addSubview:transitionContainerView];
        objc_setAssociatedObject(self, _cmd, transitionContainerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [transitionContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
        }];
    }
    return objc_getAssociatedObject(self, _cmd);
}

/** 上一个导航栏 */
- (void)setZb_preNavigationBarView:(UIView *)zb_preNavigationBarView {
    objc_setAssociatedObject(self, @selector(zb_preNavigationBarView), zb_preNavigationBarView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
/** 上一个导航栏 */
- (UIView *)zb_preNavigationBarView {
    return objc_getAssociatedObject(self, _cmd);
}

/** 当前导航栏 */
- (void)setZb_currentNavigationBarView:(UIView *)zb_currentNavigationBarView {
    objc_setAssociatedObject(self, @selector(zb_currentNavigationBarView), zb_currentNavigationBarView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
/** 当前导航栏 */
- (UIView *)zb_currentNavigationBarView {
    return objc_getAssociatedObject(self, _cmd);
}

/** 上一个导航栏截图 */
- (void)setZb_preNavigationBarSnapView:(UIView *)zb_preNavigationBarSnapView {
    objc_setAssociatedObject(self, @selector(zb_preNavigationBarSnapView), zb_preNavigationBarSnapView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
/** 上一个导航栏截图 */
- (UIView *)zb_preNavigationBarSnapView {
    return objc_getAssociatedObject(self, _cmd);
}

/** 当前导航栏截图 */
- (void)setZb_currentNavigationBarSnapView:(UIView *)zb_currentNavigationBarSnapView {
    objc_setAssociatedObject(self, @selector(zb_currentNavigationBarSnapView), zb_currentNavigationBarSnapView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
/** 当前导航栏截图 */
- (UIView *)zb_currentNavigationBarSnapView {
    return objc_getAssociatedObject(self, _cmd);
}

/** 标识是否开始过渡 */
- (void)setZb_beginTransition:(BOOL)zb_beginTransition {
    objc_setAssociatedObject(self, @selector(zb_isBeginTransition), @(zb_beginTransition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
/** 标识是否开始过渡 */
- (BOOL)zb_isBeginTransition {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

#pragma mark - MethodSwizzling -- Runtime方法交换
+ (void)load {
    
    // 监听过渡
    method_exchangeImplementations(class_getInstanceMethod(self, NSSelectorFromString(@"_updateInteractiveTransition:")),
                                   class_getInstanceMethod(self, @selector(zb_updateInteractiveTransition:)));
    
    // 监听过渡完成
    method_exchangeImplementations(class_getInstanceMethod(self, NSSelectorFromString(@"_finishInteractiveTransition:transitionContext:")),
                                   class_getInstanceMethod(self, @selector(zb_finishInteractiveTransition:transitionContext:)));
    // 监听过渡取消
    method_exchangeImplementations(class_getInstanceMethod(self, NSSelectorFromString(@"_cancelInteractiveTransition:transitionContext:")),
                                   class_getInstanceMethod(self, @selector(zb_cancelInteractiveTransition:transitionContext:)));
}


#pragma mark - Private -- 私有方法
/**
 当过渡动画取消时被调用
 */
- (void)zb_cancelInteractiveTransition:(id)obj1 transitionContext:(void *)obj2 {
    [self zb_cancelInteractiveTransition:obj1 transitionContext:obj2];
    [self zb_completeInteractiveTransitionIsCancel:YES
                                   percentComplete:[[obj1 valueForKeyPath:@"previousPercentComplete"] floatValue]
                                          duration:[[obj1 valueForKeyPath:@"_duration"] floatValue]];
}
/**
 当过渡动画完成时被调用
 */
- (void)zb_finishInteractiveTransition:(id)obj1 transitionContext:(void *)obj2 {
    [self zb_finishInteractiveTransition:obj1 transitionContext:obj2];
    [self zb_completeInteractiveTransitionIsCancel:NO
                                   percentComplete:[[obj1 valueForKeyPath:@"previousPercentComplete"] floatValue]
                                          duration:[[obj1 valueForKeyPath:@"_duration"] floatValue]];
}

// 截图
- (UIView *)zb_snapWithView:(UIView *)view {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    imageView.image = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(view.frame.size.height - 3, view.frame.size.width * 0.5 - 1, view.frame.size.height - 2, view.frame.size.width * 0.5 + 1)];
    UIGraphicsEndImageContext();
    return imageView;
}

- (void)zb_updateInteractiveTransition:(CGFloat)percentComplete {
    [self zb_updateInteractiveTransition:percentComplete];
    
    if (self.zb_isBeginTransition) {
        [self zb_navigationBarTransition:percentComplete];
    } else {
        [self zb_navigationBarBeginTransition:percentComplete];
    }
}

/**
 开始过渡

 @param percentComplete 过渡完成百分比
 */
- (void)zb_navigationBarBeginTransition:(CGFloat)percentComplete {
    
    self.zb_preNavigationBarView = objc_getAssociatedObject(self.topViewController, @selector(zb_navigationBar));
    // 不能动画直接返回
    if (![self zb_canTransitionView:self.zb_preNavigationBarView]) return;
    
    self.zb_currentNavigationBarView = objc_getAssociatedObject([self disappearingViewController], @selector(zb_navigationBar));
    // 不能动画直接返回
    if (![self zb_canTransitionView:self.zb_currentNavigationBarView]) return;
    
    // 可以进行动画
    self.zb_preNavigationBarSnapView = [self zb_snapWithView:self.zb_preNavigationBarView];
    self.zb_currentNavigationBarSnapView = [self zb_snapWithView:self.zb_currentNavigationBarView];
    
    if (self.zb_preNavigationBarSnapView.frame.size.height > self.zb_currentNavigationBarSnapView.frame.size.height) {
        self.zb_preNavigationBarSnapView.contentMode = UIViewContentModeTop;
        self.zb_currentNavigationBarSnapView.contentMode = UIViewContentModeScaleToFill;
    } else {
        self.zb_currentNavigationBarSnapView.contentMode = UIViewContentModeTop;
        self.zb_preNavigationBarSnapView.contentMode = UIViewContentModeScaleToFill;
    }
    
    [self zb_navigationBarTransition:percentComplete];
    
    self.zb_preNavigationBarView.hidden = YES;
    self.zb_currentNavigationBarView.hidden = YES;
    
    [self.zb_transitionContainerView addSubview:self.zb_preNavigationBarSnapView];
    [self.zb_transitionContainerView addSubview:self.zb_currentNavigationBarSnapView];
    
    [self.zb_preNavigationBarSnapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.zb_currentNavigationBarSnapView);
    }];
    
    [self.zb_transitionContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.zb_currentNavigationBarSnapView);
    }];
    
    [self.zb_currentNavigationBarSnapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
    }];
    
    self.zb_beginTransition = YES;
}

/**
 过渡中
 
 @param percentComplete 过渡完成百分比
 */
- (void)zb_navigationBarTransition:(CGFloat)percentComplete {
    
    self.zb_preNavigationBarSnapView.alpha = percentComplete;
    self.zb_currentNavigationBarSnapView.alpha = 1 - percentComplete;
    
    [self.zb_currentNavigationBarSnapView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.zb_currentNavigationBarView.frame.size.height - percentComplete * (self.zb_currentNavigationBarView.frame.size.height - self.zb_preNavigationBarView.frame.size.height));
    }];
}

/**
 完成剩余部分的交互动画

 @param isCancel 如果为YES标识取消，否则表示完成
 @param percentComplete 过渡完成百分比
 @param duration 完成时间
 */
- (void)zb_completeInteractiveTransitionIsCancel:(BOOL)isCancel
                                 percentComplete:(CGFloat)percentComplete
                                        duration:(CGFloat)duration  {
    
    if ([self zb_canTransitionView:self.zb_preNavigationBarView] &&
        [self zb_canTransitionView:self.zb_currentNavigationBarView]) {
        
        [UIView animateWithDuration:(isCancel ? percentComplete : (1 - percentComplete)) * duration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self zb_navigationBarTransition:!isCancel];
                         } completion:^(BOOL finished) {
                             
                             self.zb_beginTransition = NO;
                             
                             self.zb_preNavigationBarView.hidden = NO;
                             self.zb_preNavigationBarView = nil;
                             [self.zb_preNavigationBarSnapView removeFromSuperview];
                             self.zb_preNavigationBarSnapView = nil;
                             
                             self.zb_currentNavigationBarView.hidden = NO;
                             self.zb_currentNavigationBarView = nil;
                             [self.zb_currentNavigationBarSnapView removeFromSuperview];
                             self.zb_currentNavigationBarSnapView = nil;
                         }];
    }
}

/**
 判断是否可以进行过渡

 @param view 导航栏截图
 @return 是否可以进行过渡
 */
- (BOOL)zb_canTransitionView:(UIView *)view {
    return view && !view.isHidden && view.alpha > 0;
}

#pragma mark - Override -- 重写方法

#pragma mark - Public -- 公有方法

#pragma mark - Delegate -- 代理方法，每个代理新建一个mark。


@end

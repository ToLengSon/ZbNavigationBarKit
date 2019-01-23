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

@property (nonatomic, strong) UIView *zb_transitionContainerView;

@property (nonatomic, weak) ZbNavigationBar *zb_preNavigationBarView;

@property (nonatomic, weak) ZbNavigationBar *zb_currentNavigationBarView;

@property (nonatomic, strong) UIView *zb_preNavigationBarSnapView;

@property (nonatomic, strong) UIView *zb_currentNavigationBarSnapView;

@property (nonatomic, assign, getter=zb_isBeginTransition) BOOL zb_beginTransition;

- (UIViewController *)disappearingViewController;

@end


@implementation UINavigationController (ZbNavigationBarKit)

#pragma mark - Getter&Setter -- 懒加载
- (UIView *)zb_transitionContainerView {
    if (!objc_getAssociatedObject(self, _cmd)) {
        UIView *transitionContainerView = [[UIView alloc] init];
        transitionContainerView.userInteractionEnabled = NO;
        transitionContainerView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:transitionContainerView];
        objc_setAssociatedObject(self, _cmd, transitionContainerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [transitionContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
        }];
    }
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setZb_preNavigationBarView:(UIView *)zb_preNavigationBarView {
    objc_setAssociatedObject(self, @selector(zb_preNavigationBarView), zb_preNavigationBarView, OBJC_ASSOCIATION_ASSIGN);
}

- (UIView *)zb_preNavigationBarView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setZb_currentNavigationBarView:(UIView *)zb_currentNavigationBarView {
    objc_setAssociatedObject(self, @selector(zb_currentNavigationBarView), zb_currentNavigationBarView, OBJC_ASSOCIATION_ASSIGN);
}

- (UIView *)zb_currentNavigationBarView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setZb_preNavigationBarSnapView:(UIView *)zb_preNavigationBarSnapView {
    objc_setAssociatedObject(self, @selector(zb_preNavigationBarSnapView), zb_preNavigationBarSnapView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)zb_preNavigationBarSnapView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setZb_currentNavigationBarSnapView:(UIView *)zb_currentNavigationBarSnapView {
    objc_setAssociatedObject(self, @selector(zb_currentNavigationBarSnapView), zb_currentNavigationBarSnapView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)zb_currentNavigationBarSnapView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setZb_beginTransition:(BOOL)zb_beginTransition {
    objc_setAssociatedObject(self, @selector(zb_isBeginTransition), @(zb_beginTransition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)zb_isBeginTransition {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

#pragma mark - MethodSwizzling -- Runtime方法交换
+ (void)load {
    
    // 监听过渡
    method_exchangeImplementations(class_getInstanceMethod(self, NSSelectorFromString(@"_updateInteractiveTransition:")),
                                   class_getInstanceMethod(self, @selector(zb_updateInteractiveTransition:)));
    // 监听动画结束
    method_exchangeImplementations(class_getInstanceMethod(self, NSSelectorFromString(@"_navigationBarDidEndAnimation:")),
                                   class_getInstanceMethod(self, @selector(zb_navigationBarDidEndAnimation:)));
}


#pragma mark - Private -- 私有方法
- (void)zb_updateInteractiveTransition:(CGFloat)percentComplete {
    [self zb_updateInteractiveTransition:percentComplete];
    
    if (self.zb_isBeginTransition) {
        [self zb_navigationBarTransition:percentComplete];
    } else {
        [self zb_navigationBarBeginTransition:percentComplete];
    }
}

- (void)zb_navigationBarBeginTransition:(CGFloat)percentComplete {
    
    self.zb_preNavigationBarView = objc_getAssociatedObject(self.topViewController, @selector(zb_navigationBar));
    // 不能动画直接返回
    if (![self zb_canTransitionView:self.zb_preNavigationBarView]) return;
    
    self.zb_currentNavigationBarView = objc_getAssociatedObject([self disappearingViewController], @selector(zb_navigationBar));
    // 不能动画直接返回
    if (![self zb_canTransitionView:self.zb_preNavigationBarView]) return;
    
    // 可以进行动画
    self.zb_preNavigationBarSnapView = [self.zb_preNavigationBarView zb_snap];
    self.zb_currentNavigationBarSnapView = [self.zb_currentNavigationBarView zb_snap];
    
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

- (void)zb_navigationBarTransition:(CGFloat)percentComplete {
    
    self.zb_preNavigationBarSnapView.alpha = percentComplete;
    self.zb_currentNavigationBarSnapView.alpha = 1 - percentComplete;
    
    [self.zb_currentNavigationBarSnapView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.zb_currentNavigationBarView.frame.size.height - percentComplete * (self.zb_currentNavigationBarView.frame.size.height - self.zb_preNavigationBarView.frame.size.height));
    }];
}

- (void)zb_navigationBarDidEndAnimation:(UINavigationBar *)navigationBar {
    [self zb_navigationBarDidEndAnimation:navigationBar];
    
    self.zb_beginTransition = NO;
    
    self.zb_preNavigationBarView.hidden = NO;
    self.zb_preNavigationBarView = nil;
    [self.zb_preNavigationBarSnapView removeFromSuperview];
    self.zb_preNavigationBarSnapView = nil;
    
    self.zb_currentNavigationBarView.hidden = NO;
    self.zb_currentNavigationBarView = nil;
    [self.zb_currentNavigationBarSnapView removeFromSuperview];
    self.zb_currentNavigationBarSnapView = nil;
}

- (BOOL)zb_canTransitionView:(UIView *)view {
    return view && !view.isHidden && view.alpha > 0;
}

//- (void)zb_addSnapView:(UIView *)snapView {
//    [self.zb_transitionContainerView addSubview:snapView];
//    [snapView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.mas_equalTo(0);
//        make.height.mas_equalTo(snapView.frame.size.height);
//    }];
//}

#pragma mark - Override -- 重写方法

#pragma mark - Public -- 公有方法

#pragma mark - Delegate -- 代理方法，每个代理新建一个mark。


@end

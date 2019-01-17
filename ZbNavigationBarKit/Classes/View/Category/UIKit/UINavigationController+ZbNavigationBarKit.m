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

@property (nonatomic, weak) UIView *zb_preNavigationBarView;

@property (nonatomic, weak) UIView *zb_currentNavigationBarView;

@property (nonatomic, strong) UIView *zb_preNavigationBarSnapView;

@property (nonatomic, strong) UIView *zb_currentNavigationBarSnapView;

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
            make.height.mas_equalTo(ZB_NAVIGATION_BAR_HEIGHT);
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

#pragma mark - MethodSwizzling -- Runtime方法交换
+ (void)load {

    // 监听过渡动画的开始
    Class clazz = NSClassFromString(@"_UINavigationInteractiveTransition");
    SEL hookSel = @selector(zb_handleNavigationTransition:);
    Method hookMethod = class_getInstanceMethod(self, hookSel);
    
    class_addMethod(clazz,
                    hookSel,
                    method_getImplementation(hookMethod),
                    method_getTypeEncoding(hookMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(clazz, NSSelectorFromString(@"handleNavigationTransition:")),
                                   class_getInstanceMethod(clazz, hookSel));
    
    // 监听过渡
    method_exchangeImplementations(class_getInstanceMethod(self, NSSelectorFromString(@"_updateInteractiveTransition:")),
                                   class_getInstanceMethod(self, @selector(zb_updateInteractiveTransition:)));
    // 监听动画结束
    method_exchangeImplementations(class_getInstanceMethod(self, NSSelectorFromString(@"_navigationBarDidEndAnimation:")),
                                   class_getInstanceMethod(self, @selector(zb_navigationBarDidEndAnimation:)));
}


#pragma mark - Private -- 私有方法
- (void)zb_handleNavigationTransition:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer {
        
    if (UIGestureRecognizerStateBegan == gestureRecognizer.state) {
        
        UINavigationController *navigationController = objc_getAssociatedObject(gestureRecognizer, @selector(zb_overrideViewDidLoad));
        
        navigationController.zb_currentNavigationBarView = objc_getAssociatedObject(navigationController.topViewController, @selector(zb_navigationBar));
        
        if (!navigationController.zb_currentNavigationBarView ||
            navigationController.zb_currentNavigationBarView.isHidden ||
            navigationController.zb_currentNavigationBarView.alpha == 0) {
            [self zb_handleNavigationTransition:gestureRecognizer];
            return;
        }
        
        navigationController.zb_currentNavigationBarSnapView = [navigationController.zb_currentNavigationBarView snapshotViewAfterScreenUpdates:NO];
        
        [self zb_handleNavigationTransition:gestureRecognizer];
        
        navigationController.zb_preNavigationBarView = objc_getAssociatedObject(navigationController.topViewController, @selector(zb_navigationBar));
        
        if (!navigationController.zb_preNavigationBarView ||
            navigationController.zb_preNavigationBarView.isHidden ||
            navigationController.zb_preNavigationBarView.alpha == 0) {
            [self zb_handleNavigationTransition:gestureRecognizer];
            return;
        }
        
        navigationController.zb_preNavigationBarSnapView = [navigationController.zb_preNavigationBarView zb_snap];
        
        // 满足过渡条件
        [navigationController.zb_transitionContainerView addSubview:navigationController.zb_preNavigationBarSnapView];
        navigationController.zb_preNavigationBarView.hidden = YES;
        [navigationController.zb_preNavigationBarSnapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [navigationController.zb_transitionContainerView addSubview:navigationController.zb_currentNavigationBarSnapView];
        navigationController.zb_currentNavigationBarView.hidden = YES;
        [navigationController.zb_currentNavigationBarSnapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    } else {
        [self zb_handleNavigationTransition:gestureRecognizer];
    }
}

- (void)zb_updateInteractiveTransition:(CGFloat)percentComplete {
    [self zb_updateInteractiveTransition:percentComplete];

    self.zb_preNavigationBarSnapView.alpha = percentComplete;
    self.zb_currentNavigationBarSnapView.alpha = 1 - percentComplete;
}

- (void)zb_navigationBarDidEndAnimation:(UINavigationBar *)navigationBar {
    [self zb_navigationBarDidEndAnimation:navigationBar];
    
    self.zb_preNavigationBarView.hidden = NO;
    self.zb_preNavigationBarView = nil;
    [self.zb_preNavigationBarSnapView removeFromSuperview];
    self.zb_preNavigationBarSnapView = nil;
    
    self.zb_currentNavigationBarView.hidden = NO;
    self.zb_currentNavigationBarView = nil;
    [self.zb_currentNavigationBarSnapView removeFromSuperview];
    self.zb_currentNavigationBarSnapView = nil;
}

#pragma mark - Override -- 重写方法
- (void)zb_overrideViewDidLoad {
    [super zb_overrideViewDidLoad];
    
    objc_setAssociatedObject(self.interactivePopGestureRecognizer, _cmd, self, OBJC_ASSOCIATION_ASSIGN);
}


#pragma mark - Public -- 公有方法


#pragma mark - Delegate -- 代理方法，每个代理新建一个mark。


@end

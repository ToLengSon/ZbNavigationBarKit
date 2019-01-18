//
//  UIViewController+ZbNavigationBarKit.m
//  ZbNavigationBarKit
//
//  Created by wsong on 2019/1/14.
//

#import "UIViewController+ZbNavigationBarKit.h"
#import "ZbNavigationBar.h"
#import "Masonry.h"
#import <objc/runtime.h>

#pragma mark - Define&StaticVar -- 静态变量和Define声明

@implementation UIViewController (ZbNavigationBarKit)

@dynamic zb_navigationBar;

#pragma mark - Getter&Setter -- 懒加载
- (void)setZb_hideSystemNavigationBar:(BOOL)zb_hideSystemNavigationBar {
    self.navigationController.navigationBar.hidden = zb_hideSystemNavigationBar;
}

- (BOOL)zb_isHideSystemNavigationBar {
    return self.navigationController.navigationBar.isHidden;
}

#pragma mark - MethodSwizzling -- Runtime方法交换
//+ (void)load {
//    method_exchangeImplementations(class_getInstanceMethod(self, @selector(viewDidLoad)),
//                                   class_getInstanceMethod(self, @selector(zb_viewDidLoad)));
//}

#pragma mark - Private -- 私有方法
//- (void)zb_viewDidLoad {
//    [self zb_viewDidLoad];
//    [self zb_overrideViewDidLoad];
//}

#pragma mark - Override -- 重写方法

#pragma mark - Public -- 公有方法
- (void)zb_overrideViewDidLoad {}

#pragma mark - Delegate -- 代理方法，每个代理新建一个mark。


@end

//
//  UIView+ZbNavigationBarKit.m
//  ZbNavigationBarKit
//
//  Created by wsong on 2019/1/15.
//

#import "UIView+ZbNavigationBarKit.h"
#import <objc/runtime.h>

#pragma mark - Define&StaticVar -- 静态变量和Define声明


@implementation UIView (ZbNavigationBarKit)


#pragma mark - Getter&Setter -- 懒加载
- (void)setZb_didAddSubviewHandler:(void (^)(UIView *))zb_didAddSubviewHandler {
    objc_setAssociatedObject(self, @selector(zb_didAddSubviewHandler), zb_didAddSubviewHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UIView *))zb_didAddSubviewHandler {
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - MethodSwizzling -- Runtime方法交换
+ (void)load {
    
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(didAddSubview:)),
                                   class_getInstanceMethod(self, @selector(zb_didAddSubview:)));
    
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(bringSubviewToFront:)),
                                   class_getInstanceMethod(self, @selector(zb_bringSubviewToFront:)));
}


#pragma mark - Private -- 私有方法
- (void)zb_didAddSubview:(UIView *)subview {
    [self zb_didAddSubview:subview];
    
    if (self.zb_didAddSubviewHandler) {
        self.zb_didAddSubviewHandler(subview);
    }
}

- (void)zb_bringSubviewToFront:(UIView *)subview {
    [self zb_bringSubviewToFront:subview];
    
    if (self.zb_didAddSubviewHandler) {
        self.zb_didAddSubviewHandler(subview);
    }
}

#pragma mark - Override -- 重写方法


#pragma mark - Public -- 公有方法


#pragma mark - Delegate -- 代理方法，每个代理新建一个mark。


@end

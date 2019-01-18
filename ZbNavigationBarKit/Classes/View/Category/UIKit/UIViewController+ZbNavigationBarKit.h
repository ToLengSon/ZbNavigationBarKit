//
//  UIViewController+ZbNavigationBarKit.h
//  ZbNavigationBarKit
//
//  Created by wsong on 2019/1/14.
//

#import <UIKit/UIKit.h>

@class ZbNavigationBar;

@interface UIViewController (ZbNavigationBarKit)


#pragma mark - Property -- 属性声明
/** Zb导航栏 */
@property (nonatomic, readonly) ZbNavigationBar *zb_navigationBar;
/** 隐藏系统的导航栏 */
@property (nonatomic, assign, getter=zb_isHideSystemNavigationBar) BOOL zb_hideSystemNavigationBar;


#pragma mark - Function -- 方法

#pragma mark - Override
/** 当viewDidLoad触发时回调 */
//- (void)zb_overrideViewDidLoad;



@end

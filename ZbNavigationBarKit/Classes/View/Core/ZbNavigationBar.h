//
//  ZbNavigationBar.h
//  Pods
//
//  Created by 王松 on 2019/1/14.
//  Copyright © 2019 ZBJT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZbNavigationBarLayoutView : UIView

/** 移除当前布局子视图 */
- (void)clearSubviews;

/**
 移除指定的子视图

 @param subview 移除的子视图
 */
- (void)clearSubview:(UIView *)subview;

@end

@class ZbNavigationBar;

@protocol ZbNavigationBarDelegate <NSObject>

@optional
/**
 返回按钮被点击时回调

 @param navigationBar 导航栏
 @return 返回YES，表示执行返回，否则不返回
 */
- (BOOL)navigationBarBackButtonShouldValidate:(ZbNavigationBar *)navigationBar;

@end

@interface ZbNavigationBar : UIView

#pragma mark - VarProperty -- 变量属性声明
@property (nonatomic, weak) id<ZbNavigationBarDelegate> delegate;

#pragma mark - 导航栏外观全局样式设置
/** 设置全局分隔线样式 */
@property (class, nonatomic, strong) UIColor *separatorColor;
/** 设置全局返回按钮图片 */
@property (class, nonatomic, strong) UIImage *backIndicatorImage;
/** 设置全局返回按钮文字 */
@property (class, nonatomic, copy) NSString *backButtonTitle;
/** 设置全局返回按钮样式，默认14大小系统字体，黑色 */
@property (class, nonatomic, strong) NSDictionary *backButtonAttributes;
/** 设置全局文字样式，默认17大小系统字体，黑色 */
@property (class, nonatomic, strong) NSDictionary *titleAttributes;

#pragma mark - 导航栏外观设置
/** 隐藏分隔线，默认为NO */
@property (nonatomic, assign, getter=isHiddenSeparator) BOOL hiddenSeparator;
/** 设置渐变色，默认为nil */
@property (nonatomic, strong) NSArray<UIColor *> *backgroundColors;
/** 渐变色起始点 */
@property (nonatomic, assign) CGPoint startPoint;
/** 渐变色结束点 */
@property (nonatomic, assign) CGPoint endPoint;
/** 设置返回按钮样式 */
@property (nonatomic, strong) NSDictionary *backButtonAttributes;
/** 设置文字样式 */
@property (nonatomic, strong) NSDictionary *titleAttributes;

#pragma mark - 导航栏内容设置
/** 标题文字 */
@property (nonatomic, copy) NSString *title;

/** 左边导航栏视图 */
@property (nonatomic, strong, readonly) ZbNavigationBarLayoutView *leftView;
/** 中间导航栏视图 */
@property (nonatomic, strong, readonly) ZbNavigationBarLayoutView *centerView;
/** 右边导航栏视图 */
@property (nonatomic, strong, readonly) ZbNavigationBarLayoutView *rightView;
/** 导航栏底部额外视图 */
@property (nonatomic, strong, readonly) ZbNavigationBarLayoutView *bottomView;

#pragma mark - Function -- 方法声明


@end

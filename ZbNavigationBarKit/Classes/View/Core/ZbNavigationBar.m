//
//  ZbNavigationBar.m
//  Pods
//
//  Created by 王松 on 2019/1/14.
//  Copyright © 2019 ZBJT. All rights reserved.
//

#import "ZbNavigationBarKit.h"
#import "Masonry.h"
#import "UIView+ZbNavigationBarKit.h"
#import <objc/runtime.h>

#pragma mark - Define&StaticVar -- 静态变量和Define声明
static NSHashTable<ZbNavigationBar *> *_sNavigationBarList;
/** 设置全局分隔线样式 */
static UIColor *_sSeparatorColor;
/** 设置全局返回按钮图片 */
static UIImage *_sBackIndicatorImage;
/** 设置全局返回按钮文字 */
static NSString *_sBackButtonTitle;
/** 设置全局返回按钮样式 */
static NSDictionary *_sBackButtonAttributes;
/** 设置全局标题样式 */
static NSDictionary *_sTitleAttributes;

@implementation ZbNavigationBarLayoutView

- (void)removeFromSuperview {}

- (void)clearSubview:(UIView *)subview {
    if (subview.superview == self) {
        [subview removeFromSuperview];
    }
}

- (void)clearSubviews {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end


@interface ZbNavigationBar ()

/** 分隔线 */
@property (nonatomic, strong) UIView *separator;
/** 返回按钮 */
@property (nonatomic, strong) UIButton *backButton;
/** 内容容器 */
@property (nonatomic, strong) UIView *barContainer;
/** 标题 */
@property (nonatomic, strong) UILabel *titleLabel;
/** 渐变背景色 */
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
/** 上一个控制器 */
@property (nonatomic, weak) UIViewController *preViewController;
/** 当前所在的控制器 */
@property (nonatomic, weak) UIViewController *currentViewController;

@end

@implementation ZbNavigationBar

@synthesize leftView = _leftView;
@synthesize centerView = _centerView;
@synthesize rightView = _rightView;
@synthesize bottomView = _bottomView;

#pragma mark - Life Circle -- 生命周期和初始化设置

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sNavigationBarList = [NSHashTable weakObjectsHashTable];
        _sBackButtonAttributes = @{
                                   NSFontAttributeName : [UIFont systemFontOfSize:14],
                                   NSForegroundColorAttributeName : [UIColor blackColor]
                                   };
        _sTitleAttributes = @{
                              NSFontAttributeName : [UIFont systemFontOfSize:17],
                              NSForegroundColorAttributeName : [UIColor blackColor]
                              };
        _sSeparatorColor = [UIColor colorWithRed:204 / 255.0 green:204 / 255.0 blue:204 / 255.0 alpha:1];
    });
}
/**
 *  视图初始化
 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configZbNavigationBarViewAndConstraint];
        [_sNavigationBarList addObject:self];
    }
    return self;
}


#pragma mark - Config Constraint -- 视图布局配置

/**
 *  初始化View对象并设置View之间的约束
 */
- (void)configZbNavigationBarViewAndConstraint {
    self.backgroundColor = [UIColor whiteColor];
    // 初始化时就有分割线
    self.separator = [[UIView alloc] init];
    self.separator.backgroundColor = _sSeparatorColor;
    [self addSubview:self.separator];
    [self.separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
    
    _barContainer = [[UIView alloc] init];
    [self addSubview:_barContainer];
    [_barContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.separator.mas_top).priorityLow();
        CGFloat top = [UIApplication sharedApplication].statusBarFrame.size.height;
        make.top.mas_equalTo(top);
        make.height.mas_equalTo(ZB_NAVIGATION_BAR_HEIGHT - top);
    }];
}

#pragma mark - Getter&Setter -- 懒加载
- (void)setHiddenSeparator:(BOOL)hiddenSeparator {
    self.separator.hidden = hiddenSeparator;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    [self setupTitleAttributes];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.centerView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return _titleLabel;
}

- (void)setTitleAttributes:(NSDictionary *)titleAttributes {
    _titleAttributes = titleAttributes;
    
    [self setupTitleAttributes];
}

- (void)setBackButtonAttributes:(NSDictionary *)backButtonAttributes {
    _backButtonAttributes = backButtonAttributes;
    
    [self setupBackButtonAttributes];
}

- (ZbNavigationBarLayoutView *)leftView {
    if (!_leftView) {
        _leftView = [[ZbNavigationBarLayoutView alloc] init];
        [_barContainer addSubview:_leftView];
        [_leftView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            
            UIView *leftView = self->_backButton;
            
            if (leftView) {
                make.left.mas_equalTo(leftView.mas_right);
            } else {
                make.left.mas_equalTo(0);
            }
            
            UIView *rightView = self->_centerView;
            if (!rightView) {
                rightView = self->_rightView;
            }
            if (rightView) {
                make.right.mas_lessThanOrEqualTo(rightView.mas_left);
            } else {
                make.right.mas_lessThanOrEqualTo(0);
            }
        }];
    }
    return _leftView;
}

- (ZbNavigationBarLayoutView *)centerView {
    if (!_centerView) {
        _centerView = [[ZbNavigationBarLayoutView alloc] init];
        [_barContainer addSubview:_centerView];
        [_centerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.centerX.mas_equalTo(0).priorityLow();
        }];
    }
    return _centerView;
}

- (ZbNavigationBarLayoutView *)rightView {
    if (!_rightView) {
        _rightView = [[ZbNavigationBarLayoutView alloc] init];
        [_barContainer addSubview:_rightView];
        [_rightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.mas_equalTo(0);
            UIView *leftView = self->_centerView;
            if (!leftView) {
                leftView = self->_leftView;
                if (!leftView) {
                    leftView = self->_backButton;
                }
            }
            if (leftView) {
                make.left.mas_greaterThanOrEqualTo(leftView.mas_right);
            } else {
                make.left.mas_greaterThanOrEqualTo(0);
            }
        }];
    }
    return _rightView;
}

- (ZbNavigationBarLayoutView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[ZbNavigationBarLayoutView alloc] init];
        [self addSubview:_bottomView];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.separator.mas_top);
            make.top.mas_equalTo(self.barContainer.mas_bottom);
            make.left.right.mas_equalTo(0);
        }];
    }
    return _bottomView;
}

- (void)setBackgroundColors:(NSArray<UIColor *> *)backgroundColors {
    _backgroundColors = backgroundColors;
    
    if (backgroundColors) {
        NSMutableArray *cgBackgroundColors = [NSMutableArray arrayWithCapacity:backgroundColors.count];
        for (UIColor *color in backgroundColors) {
            [cgBackgroundColors addObject:(id)color.CGColor];
        }
        self.gradientLayer.colors = cgBackgroundColors;
    } else {
        [self.gradientLayer removeFromSuperlayer];
    }
}

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.startPoint = self.startPoint;
        _gradientLayer.endPoint = self.endPoint;
        [self.layer insertSublayer:_gradientLayer atIndex:0];
    }
    return _gradientLayer;
}

- (void)setStartPoint:(CGPoint)startPoint {
    _startPoint = startPoint;
    _gradientLayer.startPoint = startPoint;
}

- (void)setEndPoint:(CGPoint)endPoint {
    _endPoint = endPoint;
    _gradientLayer.endPoint = endPoint;
}

#pragma mark - 导航栏外观全局样式设置
/** 设置全局分隔线样式 */
+ (void)setSeparatorColor:(UIColor *)separatorColor {
    _sSeparatorColor = separatorColor;
    
    for (ZbNavigationBar *navigationBar in _sNavigationBarList) {
        navigationBar->_separator.backgroundColor = _sSeparatorColor;
    }
}

+ (UIColor *)separatorColor {
    return _sSeparatorColor;
}

/** 设置全局返回按钮图片 */
+ (void)setBackIndicatorImage:(UIImage *)backIndicatorImage {
    _sBackIndicatorImage = backIndicatorImage;
    
    for (ZbNavigationBar *navigationBar in _sNavigationBarList) {
        [navigationBar->_backButton setImage:[_sBackIndicatorImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    }
}

+ (UIImage *)backIndicatorImage {
    return _sBackIndicatorImage;
}

/** 设置全局返回按钮文字 */
+ (void)setBackButtonTitle:(NSString *)backButtonTitle {
    _sBackButtonTitle = backButtonTitle;
    
    for (ZbNavigationBar *navigationBar in _sNavigationBarList) {
        [navigationBar setupBackButtonAttributes];
    }
}

+ (NSString *)backButtonTitle {
    return _sBackButtonTitle;
}

+ (void)setBackButtonAttributes:(NSDictionary *)backButtonAttributes {
    _sBackButtonAttributes = backButtonAttributes;
    
    for (ZbNavigationBar *navigationBar in _sNavigationBarList) {
        if (navigationBar->_backButton.currentTitle) {
            [navigationBar->_backButton setAttributedTitle:[[NSAttributedString alloc] initWithString:navigationBar->_backButton.currentTitle attributes:_sBackButtonAttributes]
                                                  forState:UIControlStateNormal];
        }
    }
}

+ (NSDictionary *)backButtonAttributes {
    return _sBackButtonAttributes;
}

+ (void)setTitleAttributes:(NSDictionary *)titleAttributes {
    _sTitleAttributes = titleAttributes;
    
    for (ZbNavigationBar *navigationBar in _sNavigationBarList) {
        if (navigationBar->_title &&
            !navigationBar->_titleAttributes) {
            navigationBar->_titleLabel.attributedText = [[NSAttributedString alloc] initWithString:navigationBar->_title attributes:_sTitleAttributes];
        }
    }
}

+ (NSDictionary *)titleAttributes {
    return _sTitleAttributes;
}

#pragma mark - Private -- 私有方法
- (void)addBackButton {
    
    if (self.preViewController &&
        !_backButton) {
        
        _backButton = [UIButton buttonWithType:UIButtonTypeSystem];
        
        [_backButton setContentHuggingPriority:UILayoutPriorityRequired
                                       forAxis:UILayoutConstraintAxisHorizontal];
        [_backButton setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                     forAxis:UILayoutConstraintAxisHorizontal];
        _backButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        // 设置返回按钮图片
        [_backButton setImage:[_sBackIndicatorImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        // 设置返回按钮文字
        [self setupBackButtonAttributes];
        [_backButton addTarget:self
                        action:@selector(backButtonHandle)
              forControlEvents:UIControlEventTouchUpInside];
        [self.barContainer addSubview:_backButton];
        [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(5);
            make.top.bottom.mas_equalTo(0);
        }];
    }
}

- (void)setupTitleAttributes {
    
    if (_title) {
        self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:_title
                                                                         attributes:_titleAttributes ? : _sTitleAttributes];
    }
}

- (void)setupBackButtonAttributes {
    
    NSString *backButtonTitle = _sBackButtonTitle;
    
    if (!backButtonTitle) {
        ZbNavigationBar *preNavigationBar = objc_getAssociatedObject(self.preViewController, @selector(zb_navigationBar));
        backButtonTitle = preNavigationBar.title;
    }
    [_backButton setAttributedTitle:[[NSAttributedString alloc] initWithString:backButtonTitle attributes:_backButtonAttributes ? : _sBackButtonAttributes]
                           forState:UIControlStateNormal];
}

- (void)backButtonHandle {
    
    BOOL canPop = ![self.delegate respondsToSelector:@selector(navigationBarBackButtonShouldValidate:)] ||
    [self.delegate navigationBarBackButtonShouldValidate:self];
    
    if (canPop) {
        [self.currentViewController.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Override -- 重写方法
- (void)layoutSubviews {
    [super layoutSubviews];
    
    _gradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

#pragma mark - Public -- 公有方法


#pragma mark - Delegate -- 代理方法，每个代理新建一个mark。


@end

@implementation UIViewController (ZbNavigationBarRelation)

+ (void)load {
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(willMoveToParentViewController:)),
                                   class_getInstanceMethod(self, @selector(zb_willMoveToParentViewController:)));
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(didMoveToParentViewController:)),
                                   class_getInstanceMethod(self, @selector(zb_didMoveToParentViewController:)));
}

- (void)zb_willMoveToParentViewController:(UINavigationController *)parent {
    [self zb_willMoveToParentViewController:parent];
    
    if ([parent isKindOfClass:[UINavigationController class]] &&
        parent.viewControllers.count > 1) {
        
        ZbNavigationBar *navigationBar = objc_getAssociatedObject(parent.topViewController, @selector(zb_navigationBar));
        navigationBar.preViewController = parent.viewControllers[parent.viewControllers.count - 2];
        navigationBar.currentViewController = parent.topViewController;
        [navigationBar addBackButton];
    }
}

- (void)zb_didMoveToParentViewController:(UIViewController *)parent {
    [self zb_didMoveToParentViewController:parent];
}

- (ZbNavigationBar *)zb_navigationBar {
    
    if (!objc_getAssociatedObject(self, _cmd)) {
        
        ZbNavigationBar *navigationBar = [[ZbNavigationBar alloc] init];
        
        __weak typeof(self.view) weakView = self.view;
        
        self.view.zb_didAddSubviewHandler = ^(UIView *subview) {
            if (subview == navigationBar) {
                return;
            }
            [weakView bringSubviewToFront:navigationBar];
        };
        [self.view addSubview:navigationBar];
        objc_setAssociatedObject(self, _cmd, navigationBar, OBJC_ASSOCIATION_ASSIGN);
        [navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.mas_equalTo(0);
        }];
        
        navigationBar.currentViewController = self;
        if (self.navigationController.viewControllers.count > 1) {
            navigationBar.preViewController = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
            [navigationBar addBackButton];
        }
        self.zb_hideSystemNavigationBar = YES;
    }
    return objc_getAssociatedObject(self, _cmd);
}

@end

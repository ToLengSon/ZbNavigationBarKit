//
//  ZbDemoViewController.m
//  ZbNavigationBarKit_Example
//
//  Created by wsong on 2019/1/17.
//  Copyright © 2019 835151791@qq.com. All rights reserved.
//

#import "ZbDemoViewController.h"
#import "ZbNavigationBarKit.h"

@interface ZbDemoViewController ()
<ZbNavigationBarDelegate>

@end

@implementation ZbDemoViewController

+ (void)load {
    ZbNavigationBar.backIndicatorImage = [UIImage imageNamed:@"zjnews_news_nav_back_default_button"];
    ZbNavigationBar.backButtonAttributes = @{
                                             NSForegroundColorAttributeName : [UIColor greenColor],
                                             NSFontAttributeName : [UIFont systemFontOfSize:14]
                                             };
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.zb_navigationBar.title = @"演示样例";
    self.zb_navigationBar.backgroundColors = @[[UIColor yellowColor], [UIColor purpleColor]];
    self.zb_navigationBar.startPoint = CGPointMake(0, 0.5);
    self.zb_navigationBar.endPoint = CGPointMake(1, 0.5);
    self.zb_navigationBar.delegate = self;
    self.zb_navigationBar.titleAttributes = @{
                                              NSForegroundColorAttributeName : [UIColor blackColor],
                                              };
    self.zb_navigationBar.backButtonAttributes = @{
                                                   NSForegroundColorAttributeName : [UIColor blackColor],
                                                   };
//    self.zb_navigationBar.alpha = 0.3;
}

- (BOOL)navigationBarBackButtonShouldValidate:(ZbNavigationBar *)navigationBar {
    NSLog(@"返回按钮被点击");
    return YES;
}

@end

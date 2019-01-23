//
//  ZbTableViewController.m
//  ZbNavigationBarKit_Example
//
//  Created by wsong on 2019/1/17.
//  Copyright © 2019 835151791@qq.com. All rights reserved.
//

#import "ZbTableViewController.h"
#import "ZbNavigationBarKit.h"
#import "Masonry.h"

@interface ZbTableViewController ()
<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *data;

@property (weak, nonatomic) UIView *largeView;

@end

@implementation ZbTableViewController

+ (void)load {
    ZbNavigationBar.titleAttributes = @{
                                        NSFontAttributeName : [UIFont systemFontOfSize:17],
                                        NSForegroundColorAttributeName : [UIColor blackColor]
                                        };
//    ZbNavigationBar.backButtonTitle = @"";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.zb_navigationBar.alpha = 0.5;
    
    self.zb_navigationBar.title = @"浙江新闻";
    self.zb_navigationBar.backgroundColor = [UIColor whiteColor];
    
//    [UIColor colorWithRed:209 / 255.0
//                    green:35 / 255.0
//                     blue:36 / 255.0
//                    alpha:1];
    
    UIButton *serviceBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    
    serviceBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    serviceBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 11, 0, 0);
    [serviceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [serviceBtn setTitle:@"服务" forState:UIControlStateNormal];
    [serviceBtn setImage:[[UIImage imageNamed:@"zjnews_common_nav_service_default_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
               forState:UIControlStateNormal];
    [self.zb_navigationBar.leftView addSubview:serviceBtn];
    [serviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.mas_equalTo(0);
        make.left.mas_equalTo(3);
        make.width.mas_equalTo(65);
    }];
    
    UIButton *personBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [personBtn setImage:[[UIImage imageNamed:@"zjnews_common_nav_personalcenter_default_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
               forState:UIControlStateNormal];
    [self.zb_navigationBar.rightView addSubview:personBtn];
    [personBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-5);
        make.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(30);
    }];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [searchBtn setImage:[[UIImage imageNamed:@"zjnews_common_nav_search_default_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
               forState:UIControlStateNormal];
    [self.zb_navigationBar.rightView addSubview:searchBtn];
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(personBtn.mas_left).offset(-12);
        make.width.mas_equalTo(30);
        make.left.top.bottom.mas_equalTo(0);
    }];
    
    self.tableView.contentInset = UIEdgeInsetsMake(ZB_NAVIGATION_BAR_HEIGHT - [UIApplication sharedApplication].statusBarFrame.size.height + 35, 0, 0, 0);
    
    self.data = @[@{
                      @"title" : @"Demo演示",
                      @"vcName" : @"ZbDemoViewController"
                      },];
    
    UIView *largeView = [[UIView alloc] init];
    
    [self.zb_navigationBar.bottomView addSubview:largeView];
    self.largeView = largeView;
    [largeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
        make.height.mas_equalTo(35);
    }];
    
    UILabel *largeLabel = [[UILabel alloc] init];
    largeLabel.font = [UIFont systemFontOfSize:25];
    largeLabel.textColor = [UIColor blackColor];
    largeLabel.text = @"浙江新闻";
    [largeView addSubview:largeLabel];
    
    [largeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-5);
        make.height.mas_equalTo(30);
    }];
    self.zb_navigationBar.bottomView.backgroundColor = self.zb_navigationBar.backgroundColor;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellId];
    }
    cell.textLabel.text = self.data[0][@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:[[NSClassFromString(self.data[0][@"vcName"]) alloc] init] animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    self.zb_navigationBar.hiddenTitle = scrollView.contentOffset.y < -64 - 9;
    
    CGFloat height = -64 - scrollView.contentOffset.y;
    
    if (height < 0) {
        height = 0;
    } else if (height > 35) {
        height = 35;
    }
    
    [self.largeView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
//    NSLog(@"%f", scrollView.contentOffset.y);
    
//    CGFloat rate = scrollView.contentOffset.y / 64;
//
//    if (rate < -1) {
//        rate = 1;
//    } else if (rate >= 0) {
//        rate = 0;
//    } else {
//        rate = -rate;
//    }
//    self.zb_navigationBar.alpha = rate;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self autoBounce];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self autoBounce];
    }
}

- (void)autoBounce {
    
    if (self.largeView.frame.size.height < 35) {
        if (self.largeView.frame.size.height > 35 * 0.5) {
            [self.tableView setContentOffset:CGPointMake(0, -99) animated:YES];
        } else if (self.largeView.frame.size.height > 0) {
            [self.tableView setContentOffset:CGPointMake(0, -64) animated:YES];
        }
    }
}

@end

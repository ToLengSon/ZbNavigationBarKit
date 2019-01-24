# ZbNavigationBarKit

[![CI Status](https://img.shields.io/travis/835151791@qq.com/ZbNavigationBarKit.svg?style=flat)](https://travis-ci.org/835151791@qq.com/ZbNavigationBarKit)
[![Version](https://img.shields.io/cocoapods/v/ZbNavigationBarKit.svg?style=flat)](https://cocoapods.org/pods/ZbNavigationBarKit)
[![License](https://img.shields.io/cocoapods/l/ZbNavigationBarKit.svg?style=flat)](https://cocoapods.org/pods/ZbNavigationBarKit)
[![Platform](https://img.shields.io/cocoapods/p/ZbNavigationBarKit.svg?style=flat)](https://cocoapods.org/pods/ZbNavigationBarKit)

## 具备的能力

1. 滑动返回导航栏有很好的过渡动画
2. 导航栏主体分为左中右视图，高度定制
3. 可给导航栏添加额外视图，Demo工程实现了iOS 11的大标题
4. 支持背景渐变色
5. 可拦截导航栏返回按钮点击事件

## 不足与后期版本改进

1. 迅速滑动返回时，导航栏会有上一个页面导航栏影像瞬间闪烁，因为代码中只监听了导航控制器滑动返回的开始与结束，并未监听松手之后导航栏自动恢复，本人能力与时间有限，如果有大神知道如何监听松手之后导航栏自动恢复这个过程，请通过邮箱或者issue方式联系我，谢谢~

## Installation

ZbNavigationBarKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ZbNavigationBarKit'
```

## Author

835151791@qq.com

## License

ZbNavigationBarKit is available under the MIT license. See the LICENSE file for more info.

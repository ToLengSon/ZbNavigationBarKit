#
# Be sure to run `pod lib lint ZbNavigationBarKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZbNavigationBarKit'
  s.version          = '0.0.8'
  s.summary          = '一个简易的导航栏'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  一个简易的导航栏
                       DESC

  s.homepage         = 'https://github.com/ToLengSon/ZbNavigationBarKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '835151791@qq.com' => '835151791@qq.com' }
  s.source           = { :git => 'https://github.com/ToLengSon/ZbNavigationBarKit.git', :tag => s.version }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ZbNavigationBarKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ZbNavigationBarKit' => ['ZbNavigationBarKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'Masonry'
end

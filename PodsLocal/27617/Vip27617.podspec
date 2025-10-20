#
# Be sure to run `pod lib lint GLPurchaseDemo.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Vip27617'
  s.version          = '0.1.0'
  s.summary          = 'A short description of GLPurchaseDemo.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://gitlab.glority.cn/outsourcing/ios/convert-ios'
  s.author           = { 'chen.zuying' => 'wang.zhilong@glority.com' }
  s.source           = { :git => 'https://gitlab.glority.cn/outsourcing/ios/convert-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.swift_version = '5.0'
  s.ios.deployment_target = '15.0'

  s.source_files = 'GLPurchaseUI/Classes/**/*'
  
  s.resource = ['GLPurchaseUI/Assets/*.xcassets', 'GLPurchaseUI/Assets/*.mp4', 'GLPurchaseUI/Assets/Localizable/*.lproj/*']
  
  s.dependency 'GLPurchaseUI', ">= 6.6.0"
  s.dependency 'GLCore'
  s.dependency 'GLResource', ">= 0.10.1"
  s.dependency 'GLConfig_Extension'
  s.dependency 'GLTrackingExtension'
  s.dependency 'GLLottie'
  
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

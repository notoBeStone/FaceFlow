#
# Be sure to run `pod lib lint GLManageSubscription.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GLMSubDefault'
  s.version          = '1.0.0'
  s.summary          = 'A short description of GLMSubDefault.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://gitlab.glority.cn/outsourcing/ios/manage-subscription'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'peng.ruilin' => 'peng.ruilin@gloritysolutions.com' }
  s.source           = { :git => 'https://gitlab.glority.cn/outsourcing/ios/manage-subscription.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '15.0'
  s.swift_versions = ['5.0']

  s.source_files = 'GLMSubDefault/Classes/**/*'
  s.resource = ['GLMSubDefault/Assets/*.xcassets', 'GLMSubDefault/Assets/Localizable/*.lproj/*']
  
   s.dependency 'GLCore'
   s.dependency 'GLComponentAPI'
   s.dependency 'GLAccountExtension'
   s.dependency 'GLPurchaseExtension'
   s.dependency 'GLManageSubscriptionBase'
   s.dependency 'GLResource'
   s.dependency 'GLUtils'
   s.dependency 'GLWidget'
   s.dependency 'GLTrackingExtension'
   s.dependency 'GLAnalyticsUI'

end

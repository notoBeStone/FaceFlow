#
# Be sure to run `pod lib lint GLBizStorage.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GLBizStorage'
  s.version          = '0.1.0'
  s.summary          = 'A short description of GLBizStorage.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/wang.zhilong/GLBizStorage'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wang.zhilong' => 'wang.zhilong@glority.cn' }
  s.source           = { :git => 'https://github.com/wang.zhilong/GLBizStorage.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '15.0'
  s.swift_version = '5.1'

  s.source_files = 'GLBizStorage/Classes/**/*'
  s.dependency 'AppModels'
    s.dependency 'GLConfig_Extension'
    s.dependency 'GLResource'
    s.dependency 'GLCore'
    s.dependency 'GLUtils'
    s.dependency 'GLBaseApi'
    s.dependency 'GLNetworking'
    s.dependency 'DGMessageAPI'
    s.dependency 'GLNetworkingMessage'
    s.dependency 'GLAccountExtension'
    s.dependency 'GLDatabase'
    s.dependency 'GLABTestingExtension'
    s.dependency 'GLMP'
    s.dependency 'GLWidget'
    s.dependency 'GLImageProcess'
    s.dependency 'GLCMSSearch_Extension'
    s.dependency 'GLComponentAPI'
    s.dependency 'GRDB.swift'
end

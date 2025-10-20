Pod::Spec.new do |s|
  s.name             = 'AppDebuggerExtension'
  s.version          = '0.1.0'
  s.summary          = 'A short description of GLAnalytics.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://gitlab.glority.cn/component/ios/base/gl-analytics'
  s.author           = { 'xie.longyan' => 'xie.longyan@gloritysolutions.com' }
  s.source           = { :git => 'https://gitlab.glority.cn/component/ios/base/gl-analytics.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
  
  s.dependency 'GLCore'
  
  s.source_files = 'Classes/**/*'

end

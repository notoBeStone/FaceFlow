Pod::Spec.new do |s|
  s.name             = 'AppDebugger'
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
  
  s.dependency 'GLDebugger', '>=0.1.5'
  s.dependency 'GLCore'
  s.dependency 'DGMessageAPI'
  s.dependency 'GLWidget'
  s.dependency 'GLUtils'
  
  # HostDebugger
  s.subspec 'HostDebugger' do |c|
    c.source_files = 'HostDebugger/Classes/**/*'
    c.dependency 'GLConfig_Extension'
    c.dependency 'GLConfig'
    c.dependency 'GLDatabase'
  end
  
  s.subspec 'CacheDebugger' do |c|
    c.source_files = 'CacheDebugger/Classes/**/*'
    c.dependency 'GLDatabase'
    c.dependency 'GLAccountExtension'
    c.dependency 'AppRepository'
  end

end

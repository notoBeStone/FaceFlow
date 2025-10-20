
Pod::Spec.new do |s|
    s.name             = 'AppModels'
    s.version          = '0.1.0'
    s.summary          = 'Java Api'
  
    s.description      = <<-DESC
    Java Api
                         DESC
  
    s.homepage         = 'https://gitlab.glority.cn/incubator/ios/homedeco'
    s.author           = { 'xie.longyan' => 'xie.longyan@gloritysolutions.com' }
    s.source           = { :git => 'https://gitlab.glority.cn/incubator/ios/homedeco.git', :tag => s.version.to_s }
  
    s.ios.deployment_target = '11.0'
    s.swift_version = '5.0'
    
    s.dependency 'DGMessageAPI'
    s.dependency 'GLComponentAPI'
    s.dependency 'GLImageProcess'
    s.dependency 'GLCore'
    s.dependency 'GLWebImageExtension'
    s.dependency 'GLWidget'
    
    s.source_files = 'AppModels/**/*'
    
  end
  

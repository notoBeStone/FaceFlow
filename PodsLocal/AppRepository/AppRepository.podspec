
Pod::Spec.new do |s|
    s.name             = 'AppRepository'
    s.version          = '0.1.0'
    s.summary          = 'App Repository'
  
    s.description      = <<-DESC
    App Repository
                         DESC
  
    s.homepage         = 'https://gitlab.glority.cn/incubator/ios/apprepository'
    s.author           = { 'xie.longyan' => 'xie.longyan@gloritysolutions.com' }
    s.source           = { :git => 'https://gitlab.glority.cn/incubator/ios/apprepository.git', :tag => s.version.to_s }
  
    s.ios.deployment_target = '11.0'
    s.swift_version = '5.0'


    s.source_files = 'AppRepository/Classes/**/*'
    s.resources = 'AppRepository/Assets/**/*'
    
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
  end
  

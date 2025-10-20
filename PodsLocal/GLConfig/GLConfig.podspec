
Pod::Spec.new do |s|
    s.name             = 'GLConfig'
    s.version          = '0.1.0'
    s.summary          = 'App Config'
  
    s.description      = <<-DESC
    App Config
                         DESC
  
    s.homepage         = 'https://gitlab.glority.cn/incubator/ios/template'
    s.author           = { 'xie.longyan' => 'xie.longyan@glority.cn' }
    s.source           = { :git => 'https://gitlab.glority.cn/incubator/ios/template.git', :tag => s.version.to_s }
  
    s.source_files = 'GLConfig/**/*'

    s.ios.deployment_target = '11.0'
    s.swift_version = '5.0'

    s.dependency 'GLCore'
    s.dependency 'GLPurchaseExtension'
    s.dependency 'GLPurchaseUIExtension'
        
end

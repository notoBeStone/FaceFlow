
Pod::Spec.new do |s|
    s.name             = 'GLMP'
    s.version          = '0.1.1'
    s.summary          = 'App GLMP'
  
    s.description      = <<-DESC
    App Repository
                         DESC
  
    s.homepage         = 'https://gitlab.glority.cn/incubator/ios/glmp'
    s.author           = { 'xie.longyan' => 'xie.longyan@gloritysolutions.com' }
    s.source           = { :git => 'https://gitlab.glority.cn/incubator/ios/glmp.git', :tag => s.version.to_s }
  
    s.ios.deployment_target = '14.0'
    s.swift_version = '5.0'

    s.source_files = 'GLMP/**/*'
    
    # Bsae
    s.dependency 'GLCore'
    s.dependency 'GLUtils'

    # GLMPCache
    s.dependency 'GLDatabase'
    
    # GLMPDAO
    s.dependency 'GRDB.swift'
    
    # GLMPNetwork
    s.dependency 'GLNetworkingMessage'
    s.dependency 'DGMessageAPI'
    s.dependency 'GLConfig_Extension'
    s.dependency 'GLBaseApi'
    s.dependency 'GLResource'
    
    # GLMPABTesting
    s.dependency 'GLABTestingExtension'
    
    # GLMPTracking
    s.dependency 'GLTrackingExtension'
    s.dependency 'GLAccountExtension'
    
    # GLMPUpload
    s.dependency 'GLCloudUploader_Extension'
    
    # GLMPAgreement
    s.dependency 'GLAgreement_Extension'
    
    # GLMPImageCache
    s.dependency 'GLWebImageExtension'

  end
  

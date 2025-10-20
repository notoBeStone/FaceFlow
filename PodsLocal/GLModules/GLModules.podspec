
Pod::Spec.new do |s|
    s.name             = 'GLModules'
    s.version          = '0.1.0'
    s.summary          = 'GLModules'
  
    s.description      = <<-DESC
    GLModules
                         DESC
  
    s.homepage         = 'https://gitlab.glority.cn/incubator/ios/glmp'
    s.author           = { 'xie.longyan' => 'xie.longyan@gloritysolutions.com' }
    s.source           = { :git => 'https://gitlab.glority.cn/incubator/ios/glmp.git', :tag => s.version.to_s }
  
    s.ios.deployment_target = '14.0'
    s.swift_version = '5.0'
    
    s.subspec 'Resources' do |r|
      r.source_files = 'GLModules/Localizable/Language.swift'
      r.resources = 'GLModules/Localizable/*.lproj/*.strings', 'GLModules/Assets/*.xcassets'
    end
    
    s.dependency 'GLCore'
    s.dependency 'GLUtils'
    s.dependency 'GLMP'
    s.dependency 'GLAnalyticsUI'
    s.dependency 'AppConfig'

    s.subspec 'AppPurchase' do |purchase|
      purchase.source_files =  ['GLModules/Classes/AppPurchase/**/*']
      purchase.dependency 'GLPurchaseExtension'
      purchase.dependency 'GLPurchaseUIExtension'
      purchase.dependency 'GLWidget'
      purchase.dependency 'SnapKit'
    end
    
    s.subspec 'AppLanuch' do |lanuch|
      lanuch.source_files =  ['GLModules/Classes/AppLanuch/**/*']
      lanuch.dependency 'GLLottie'
      lanuch.dependency 'GLPopupExtension'
      lanuch.dependency 'AppDebuggerExtension'
      lanuch.dependency 'GLDebuggerExtension'
      lanuch.dependency 'GLAdjustExtension'
      lanuch.dependency 'GLTrackingExtension'
      lanuch.dependency 'GLWebView'
      
#      lanuch.dependency 'GLModules/AppPurchase'
    end
    
    s.subspec 'Support' do |support|
      support.source_files =  ['GLModules/Classes/Support/**/*']
      support.dependency 'GLComponentAPI'
      support.dependency 'DGMessageAPI'
    end
    
    s.subspec 'Login' do |login|
      login.source_files =  ['GLModules/Classes/Login/**/*']
    end

  end
  

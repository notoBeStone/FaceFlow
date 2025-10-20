source 'https://gitlab.glority.cn/clients/component/ios/channel-specs.git'
source 'https://gitlab.glority.cn/clients/component/ios/Specs.git'
source 'https://cdn.cocoapods.org'

platform :ios, '15.0'
use_frameworks!
inhibit_all_warnings!

#--------------------------------------------------------------------------------------------------------------
# thirdLib
#--------------------------------------------------------------------------------------------------------------
def thirdlib
  pod 'SnapKit',                      '5.7.1'
#  pod 'SwiftUIX',                     '0.1.9'
  pod 'SwiftUIIntrospect',            '1.2.0'
  pod 'ExytePopupView',               '3.0.0'
  pod 'IQKeyboardManager',            '6.5.19'
  
  # https://github.com/groue/GRDB.swift?tab=readme-ov-file#installation , GLMP中数据库依赖在这里指定版本
  pod 'GRDB.swift',                   :git => 'https://github.com/groue/GRDB.swift.git',       :tag => 'v6.29.3'
  # 满足 dependency-whitelist-xx 条件可能需要使用的仓库
#  pod 'TensorFlowLiteC'
#  pod 'TensorFlowLiteSelectTfOps'
end

#--------------------------------------------------------------------------------------------------------------
# Debugger
#--------------------------------------------------------------------------------------------------------------
def debugger
  pod 'GLDebuggerExtension',          '0.1.0'
    
  # 注：被标为 Debug 的 pod 仓库，在出非 Prod 包时， CI会去将 Debug 改为 Release 并打入包内
  pod 'GLDebugger',                   '0.2.0',  :configurations => ['Debug']

  # Tracking Debugger
  pod 'GLAnalyticsDebugger',          '0.3.7',  :configurations => ['Debug']
  pod 'GLABTestingDebugger',          '4.2.2',  :configurations => ['Debug']
  
  pod 'AppDebuggerExtension',         :path => 'PodsLocal/AppDebugger/AppDebuggerExtension'
  pod 'AppDebugger',                  :path => 'PodsLocal/AppDebugger/AppDebugger',           :configurations => ['Debug']
  pod 'InjectHotReload',              :path => 'PodsLocal/Inject',                            :configurations => ['Debug']
  # LookinServer
  # pod 'LookinServer',  :configurations => ['Debug']
  
end


#--------------------------------------------------------------------------------------------------------------
# base 基础组件
#--------------------------------------------------------------------------------------------------------------
def base
  # 可不配置使用的组件
  base_nonconfigurable
  # 需配置后使用的组件
  base_configurable
end

def base_nonconfigurable
  # Core
  pod 'GLCore',                      '1.0.2'
  pod 'DGMasonry',                   '1.0.1'
  pod 'GLLottie',                    '1.5.0'
  pod 'GLUtils',                     '2.32.2'
  pod 'GLWidget',                    '2.20.4'
  pod 'GLImageProcess',              '0.5.2'
  pod 'GLTextKit',                   '1.1.4'
  pod 'GLMarkdown',                  '1.1.1'
  pod 'GLLogging',                   '1.2.3'
  pod 'GLDatabase',                  '0.7.0'
  pod 'DGPicker',                    '0.3.2'
  pod 'GLDependency',                '1.0.0'

end
  
def base_configurable
  # Resource
  pod 'GLResource',                  '0.10.1'
  # WebImage
  pod 'GLWebImageExtension',         '2.2.0'
  pod 'GLWebImage',                  '2.4.0'
  # Networking
  pod 'GLSBuilderFramework',         '1.0.1'
  pod 'GLBaseApi',                   '0.7.0'
  pod 'DGMessageAPI',                '0.15.0'
  pod 'GLComponentAPI',              '3.2.0'
  
  pod 'GLNetworkingMessage',         '0.7.2'
  pod 'GLNetworking',                '0.5.0'
  # Config
  pod 'GLConfig_Extension',          '0.23.0'
  # Account
  pod 'GLAccountExtension',          '4.2.0'
  pod 'GLAccount',                   '4.2.1'
  pod 'GLAccountUIExtension',        '0.1.6'
  pod 'GLAccountUI',                 '0.1.12'
  # ABTesting
  pod 'GLABTestingExtension',        '5.2.0'
  pod 'GLABTesting',                 '5.2.0'
  # Adjust
  pod 'GLAdjustExtension',           '3.1.0'
  pod 'GLAdjust',                    '3.2.0'
  # Agreenment
  pod 'GLAgreement_Extension',       '1.6.0'
  pod 'GLAgreement',                 '1.6.1'
  # CloudUpload
  pod 'GLCloudUploader_Extension',   '4.0.0'
  pod 'GLAwsUploader',               '4.1.0'
  # Tracking
  pod 'GLTrackingExtension',         '0.16.0'
  pod 'GLAnalytics',                 '0.14.6'
  pod 'GLAnalyticsUI',               '0.6.1'
  pod 'GLFirebase',                  '1.6.3'
  pod 'GLTrackingEvents',            '2.2.1'
  # Purchase
  pod 'GLPurchaseExtension',         '4.0.1'
  pod 'GLPurchase',                  '4.3.0'
  pod 'GLPurchaseUIExtension',       '7.2.0'
  pod 'GLPurchaseUI',                '7.2.2'
  pod 'GLOfferCode_Extension',       '1.0.1'
  pod 'GLOfferCode',                 '1.0.2'
  #  pod 'GLGrowthLaunch',              '3.1.2'
  # NPS
  pod 'GLPopup',                      :git => 'https://gitlab.glority.cn/clients/component/ios/base/gl-popup.git',     :branch => 'dev/#000-Handler'
  pod 'GLPopupExtension',             :git => 'https://gitlab.glority.cn/clients/component/ios/base/gl-popup.git',     :branch => 'dev/#000-Handler'
  
  # Camera
  pod 'GLCamera',                    '1.3.0'
  
  # WebView
  pod 'GLWebView',                   '1.0.0'

end

#--------------------------------------------------------------------------------------------------------------
# local Pods
#--------------------------------------------------------------------------------------------------------------
def local
  # Config
  pod 'GLConfig',                     :path => 'PodsLocal/GLConfig'
  pod 'AppConfig',                    :path => 'PodsLocal/AppConfig'
  pod 'AppModels',                    :path => 'PodsLocal/AppModels'
  pod 'GLBizStorage',                  :path => 'PodsLocal/GLBizStorage'
  pod 'AppRepository',                :path => 'PodsLocal/AppRepository'
  pod 'GLModules',                    :path => 'PodsLocal/GLModules'
  pod 'GLMP',                         :path => 'PodsLocal/GLMP'
end

#--------------------------------------------------------------------------------------------------------------
# biz 业务组件
#--------------------------------------------------------------------------------------------------------------
def biz
  # GLShare
  pod 'GLShareExtension',             '1.0.4'
  pod 'GLShare',                      '1.0.6'
  pod 'GLRemoteResouce',              '0.1.1'
  # Feedback
  pod 'GLFeedback',                   '1.2.3'
  pod 'GLFeedbackExtension',          '1.2.3'

  
  pod 'GLCMSItemWebView',             '3.0.0'
  
  pod 'GLUserTag_Extension',          '1.1.1'
  pod 'GLUserTag',                    '1.1.2'
  
end

#--------------------------------------------------------------------------------------------------------------
# outsourcing 外包/通道
#--------------------------------------------------------------------------------------------------------------
def outsourcing
    manage_subscription
    survey
    vip_page
    agreement
end

def manage_subscription
  pod 'GLManageSubscriptionBase',     '2.0.7'
  pod 'GLMSubDefault',                :path => 'PodsLocal/GLMSubDefault'
end

def survey
  # Survey
  pod 'GLSurvey_Extension',           '1.1.0'
  pod 'GLSurvey',                     '1.2.2'
  pod 'GLSurveyStyle1',               '1.0.2'
end

def vip_page
  # https://gitlab.glority.cn/outsourcing/ios/convert-ios-new.git
#  pod 'Vip27616',                :path => 'PodsLocal/27616'
#  pod 'Vip27617',                :path => 'PodsLocal/27617'
end

def agreement
end

#--------------------------------------------------------------------------------------------------------------
# Target
#--------------------------------------------------------------------------------------------------------------
def project
  thirdlib
  debugger
  base
  biz
  outsourcing
  local
end

target 'HackWeek' do
  project
end

#--------------------------------------------------------------------------------------------------------------
# Pod Hook
#--------------------------------------------------------------------------------------------------------------
post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['CODE_SIGN_IDENTITY'] = ''
        if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 15.0
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
        end
      end
    end
  end
  
  # 将 bitcode 移除脚本移到这里，确保在 Pod 安装完成后执行
  bitcode_strip_path = `xcrun --find bitcode_strip`.chop!
  
  framework_paths = [
    "Pods/GLSBuilderFramework/GLSBuilder.xcframework/ios-arm64_armv7/GLSBuilder.framework/GLSBuilder",
    "Pods/GLSBuilderFramework/GLSBuilder.xcframework/ios-arm64_i386_x86_64-simulator/GLSBuilder.framework/GLSBuilder",
    "Pods/GLMarkdown/GLMarkdown/Vendor/CocoaMarkdown.xcframework/ios-arm64/CocoaMarkdown.framework/CocoaMarkdown",
    "Pods/GLMarkdown/GLMarkdown/Vendor/CocoaMarkdown.xcframework/ios-arm64_x86_64-simulator/CocoaMarkdown.framework/CocoaMarkdown"
  ]
  
  framework_paths.each do |framework_relative_path|
    strip_bitcode_from_framework(bitcode_strip_path, framework_relative_path)
  end
end

def strip_bitcode_from_framework(bitcode_strip_path, framework_relative_path)
  framework_path = File.join(Dir.pwd, framework_relative_path)
  command = "#{bitcode_strip_path} #{framework_path} -r -o #{framework_path}"
  puts "Stripping bitcode: #{command}"
  system(command)
end

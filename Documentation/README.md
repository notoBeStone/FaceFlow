# HackWeek 文档中心

## 概述

HackWeek 是一个基于企业级架构的 iOS 开发模板，专门为非专业 iOS 开发者提供快速开发 MVP 应用的完整解决方案。本文档中心提供了完整的技术文档、使用指南和最佳实践。

## 📚 文档结构

```
Documentation/
├── README.md                           # 本文档
├── Guides/                             # 使用指南
│   ├── CoreCapabilities.md            # 四大核心能力映射
│   ├── LLM_Usage_Guide.md             # LLM 调用服务指南
│   ├── Navigator_Usage_Guide.md       # 路由系统使用指南
│   ├── Camera_Usage_Guide.md          # 拍照功能使用指南
│   ├── DataPersistence_Usage_Guide.md # 数据持久化指南
│   ├── Prompt_Engineering_Guide.md    # AI 编程提示词指南 (待创建)
│   ├── Code_Generation_Templates.md   # 代码生成模板 (待创建)
│   └── Troubleshooting_Guide.md       # 故障排除指南 (待创建)
├── Modules/                            # 模块详细文档
│   ├── Incubator/README.md            # Incubator 基础设施模块
│   ├── Onboarding/README.md           # Onboarding 用户引导模块
│   ├── WordBook/README.md             # WordBook 单词学习模块
│   └── VipConversion/README.md        # VipConversion 付费转化模块
└── API/                                # API 参考文档 (待完善)
```

## 🎯 核心特性

### 四大核心能力

1. **🗺️ 路由系统 (Navigator Pattern)**
   - 统一的页面导航管理
   - 自动埋点追踪
   - 类型安全保证
   - 详细指南: [Navigator 使用指南](Guides/Navigator_Usage_Guide.md)

2. **📸 拍照功能 (Camera Integration)**
   - 完整的相机和图片处理系统
   - VisionKit 抠图功能
   - 图片上传和存储
   - 详细指南: [拍照功能指南](Guides/Camera_Usage_Guide.md)

3. **🤖 LLM 调用服务 (AI Integration)**
   - 标准化的 AI 服务集成
   - 文本分析和图片识别
   - 会话管理和错误处理
   - 详细指南: [LLM 使用指南](Guides/LLM_Usage_Guide.md)

4. **💾 数据结构管理 (Data Persistence)**
   - 基于 SwiftData 的数据持久化
   - CRUD 操作接口
   - 学习算法集成
   - 详细指南: [数据持久化指南](Guides/DataPersistence_Usage_Guide.md)

## 🚀 快速开始

### 对于使用 AI 编程工具的开发者

1. **了解架构概览**: [核心能力映射](Guides/CoreCapabilities.md)
2. **学习导航系统**: [Navigator 使用指南](Guides/Navigator_Usage_Guide.md)
3. **掌握 AI 编程技巧**: [提示词工程指南](Guides/Prompt_Engineering_Guide.md) (待创建)
4. **使用代码模板**: [代码生成模板](Guides/Code_Generation_Templates.md) (待创建)

### 对于其他端开发者

1. **了解架构概览**: [核心能力映射](Guides/CoreCapabilities.md)
2. **学习导航系统**: [Navigator 使用指南](Guides/Navigator_Usage_Guide.md)
3. **查看模块文档**: [模块文档索引](Modules/)
4. **参考 API 文档**: [API 参考](API/) (待完善)

## 📖 模块文档

### 基础设施模块
- **[Incubator](Modules/Incubator/README.md)** - 导航系统、UI组件、转化功能

### 功能模块
- **[Onboarding](Modules/Onboarding/README.md)** - 用户引导流程
- **[WordBook](Modules/WordBook/README.md)** - 单词学习系统
- **[VipConversion](Modules/VipConversion/README.md)** - 付费转化系统

## 🔧 配置系统

### 主要配置文件

1. **TemplateConfig** - `HackWeek/TemplateAPI.swift`
   ```swift
   struct TemplateConfig {
       static var rootView: AnyView { /* 根视图配置 */ }
       static var conversionView: AnyView { /* 转化页配置 */ }
       static var showConversionAtLaunch: Bool { /* 启动时转化页逻辑 */ }
   }
   ```

2. **AppConfigMisc** - `PodsLocal/AppConfig/AppConfig/AppConfigMisc.swift`
   ```swift
   struct AppEvoConfig {
       static var skuConfig: [AppSkuConfigModel] { /* SKU 配置 */ }
   }
   ```

### 配置修改指南

对于非程序员，可以通过以下方式修改配置：

1. **修改根视图**: 在 TemplateConfig.swift 中修改 `rootView`
2. **配置 SKU**: 在 AppConfigMisc.swift 中修改 `skuConfig` 数组
3. **自定义页面**: 创建新的 SwiftUI 页面并配置到相应位置

## 🛠️ 开发指南

### 环境要求
- Xcode 15.0+
- iOS 15.0+
- CocoaPods 1.11+

### 安装和运行
```bash
# 1. 安装依赖
pod install

# 2. 打开项目
open HackWeek.xcworkspace

# 3. 选择目标和模拟器
# 目标: HackWeek
# 模拟器: iPhone 17

# 4. 构建运行
xcodebuild -workspace HackWeek.xcworkspace -scheme HackWeek -destination 'platform=iOS Simulator,name=iPhone 17' build
```

### 项目结构
```
HackWeek/
├── HackWeek/                     # 主应用
│   ├── Core/                     # 核心框架层
│   ├── Features/                 # 功能模块
│   ├── Incubator/               # 基础设施
│   └── Resources/               # 静态资源
├── PodsLocal/                   # 本地依赖
├── Pods/                        # 外部依赖
└── Documentation/               # 📚 文档中心
```

## 📊 使用示例

### 创建新页面
```swift
struct MyPage: ComposablePageComponent {
    struct Props {
        let title: String
        let onAction: () -> Void
    }

    let props: Props
    var pageName: String { "my_page" }
    var pageTrackingParams: [String: Any]? {
        [.TRACK_KEY_TYPE: "demo"]
    }

    var body: some View {
        VStack {
            Text(props.title)
            Button("Action") {
                props.onAction()
                tracking("my_page_button_click", [.TRACK_KEY_TYPE: "primary"])
            }
        }
    }
}

// 导航到新页面
Navigator.push(MyPage(props: MyPageProps(
    title: "Hello World",
    onAction: { print("Action tapped") }
)), from: "home")
```

### 使用拍照功能
```swift
struct CameraDemo: ComposablePageComponent {
    @StateObject private var viewModel = CameraDemoViewModel()

    var body: some View {
        VStack {
            if let image = viewModel.capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }

            Button("拍照") {
                viewModel.showCamera()
            }
        }
        .connect(viewModel: viewModel)
    }
}
```

## 🎯 目标用户

### 产品经理和设计师
- 了解技术实现可能性
- 快速验证产品概念
- 参与功能设计和测试

### 其他端开发者（Android、Web）
- 跨平台开发 iOS 应用
- 学习企业级架构模式
- 快速上手 iOS 开发

### iOS 初学者
- 学习最佳实践
- 了解企业级项目结构
- 获得完整的代码示例

## 🤝 贡献指南

### 文档贡献
1. 使用清晰易懂的语言
2. 提供完整的代码示例
3. 包含常见问题和解决方案
4. 考虑不同技术背景的读者

### 代码贡献
1. 遵循现有代码风格和架构模式
2. 添加必要的注释和文档
3. 确保所有功能都有测试覆盖
4. 提交前运行完整测试

## 📞 技术支持

如有问题或建议，请：
1. 查看文档和 FAQ
2. 搜索相关的模块文档
3. 参考使用指南中的示例
4. 创建新的 Issue 描述问题

## 📄 许可证

本项目采用 MIT 许可证，详见 [LICENSE](../LICENSE) 文件。

---

*HackWeek 文档中心为企业级 iOS 开发提供完整的指导和参考，让不同技术背景的开发者都能快速上手。*
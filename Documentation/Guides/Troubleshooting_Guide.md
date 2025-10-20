# 故障排除指南

本文档提供 HackWeek 项目中常见问题的诊断和解决方案，帮助开发者快速定位和修复问题。

## 🚀 编译和构建问题

### 问题 1：项目编译失败
**症状**: Xcode 显示编译错误，红色标记出现在代码中

**常见原因**:
- 语法错误
- 类型不匹配
- 缺少依赖
- 版本冲突

**诊断步骤**:
1. 查看错误信息详情
2. 检查红色标记的具体位置
3. 确认所有依赖都正确安装

**解决方案**:
```bash
# 1. 清理构建缓存
Product → Clean Build Folder (Cmd + Shift + K)

# 2. 重新安装依赖
rm -rf Pods Podfile.lock
pod install

# 3. 重新构建项目
Cmd + R
```

### 问题 2：CocoaPods 依赖问题
**症状**: `pod install` 失败或找不到依赖

**诊断步骤**:
1. 检查 CocoaPods 版本
2. 确认网络连接
3. 查看 Podfile 配置

**解决方案**:
```bash
# 更新 CocoaPods
sudo gem install cocoapods

# 清理缓存
pod cache clean --all

# 重新安装
pod install --repo-update
```

### 问题 3：Swift 版本兼容性问题
**症状**: "Swift version compatibility" 错误

**解决方案**:
1. 检查 Xcode 中的 Swift 版本设置
2. 确认所有第三方库支持当前 Swift 版本
3. 更新过时的依赖库

## 🏗️ 架构相关问题

### 问题 1：Navigator 导航不工作
**症状**: 页面跳转无响应或崩溃

**常见原因**:
- 使用了错误的导航 API
- 页面类型不匹配
- 来源标识符错误

**正确用法**:
```swift
// ✅ 正确的导航方式
TemplateAPI.Navigator.push(
    DetailView(),
    from: "home_page",
    animated: true
)

// ❌ 错误的方式
Navigator.push(DetailView())  // 缺少来源标识
TemplateAPI.Navigator.push()  // 参数不匹配
```

**诊断检查清单**:
- [ ] 使用 `TemplateAPI.Navigator` 而不是直接的 `Navigator`
- [ ] 页面组件遵循正确的协议
- [ ] 来源标识符格式正确
- [ ] 在主线程中调用导航方法

### 问题 2：数据持久化失败
**症状**: 数据无法保存或查询结果为空

**常见原因**:
- ModelContainer 配置错误
- 数据模型关系定义问题
- 保存操作未完成

**诊断代码**:
```swift
// 检查 ModelContainer
let container = ModelContainer.shared
print("Container 配置: \(container)")

// 检查数据模型
let descriptor = FetchDescriptor<YourModel>()
do {
    let items = try modelContext.fetch(descriptor)
    print("数据数量: \(items.count)")
} catch {
    print("查询失败: \(error)")
}
```

**解决方案**:
1. 确认数据模型使用 `@Model` 宏
2. 检查关系定义的正确性
3. 使用 `try modelContext.save()` 确保保存完成

### 问题 3：TemplateAPI 调用失败
**症状**: TemplateAPI 方法调用无效果或崩溃

**正确调用示例**:
```swift
// 转化功能
TemplateAPI.Conversion.showVip(from: "source_page", animationType: .present)
TemplateAPI.Conversion.enableCurrentSkus(["sku1", "sku2"])

// 导航功能
TemplateAPI.Navigator.push(NewView(), from: "current_page", animated: true)
TemplateAPI.Navigator.present(SettingsView(), from: "main", animated: true)

// AI 功能
let response = try await TemplateAPI.ChatGPT.sendMessage("Hello", systemPrompt: "You are helpful")
```

## 🎨 UI 相关问题

### 问题 1：SwiftUI 视图不更新
**症状**: 状态改变但界面没有反映

**常见原因**:
- 忘记使用 `@State` 或 `@Published`
- 错误的状态管理
- 异步更新未在主线程

**解决方案**:
```swift
// ✅ 正确的状态管理
@State private var count = 0
@Published var isLoading = false  // 在 ViewModel 中

// 异步更新必须在主线程
Task { @MainActor in
    self.isLoading = true
    // 执行异步操作
    self.isLoading = false
}
```

### 问题 2：布局问题
**症状**: 元素重叠、间距错误或响应式布局失效

**诊断工具**:
```swift
// 开启调试预览
var body: some View {
    VStack {
        // 你的内容
    }
    .border(Color.red, width: 1)  // 添加边框查看边界
    .background(Color.yellow.opacity(0.3))  // 添加背景查看区域
}
```

**常见修复**:
- 使用 `Spacer()` 调整间距
- 检查 `frame` 修饰符的设置
- 确认使用正确的布局容器（VStack/HStack）

### 问题 3：导航栏问题
**症状**: 导航栏标题不显示或按钮无响应

**解决方案**:
```swift
NavigationView {
    VStack {
        // 内容
    }
    .navigationTitle("标题")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("操作") {
                // 操作逻辑
            }
        }
    }
}
```

## 📱 设备和模拟器问题

### 问题 1：模拟器启动慢或卡顿
**症状**: 模拟器启动时间长，运行缓慢

**优化方案**:
1. 选择合适的模拟器（iPhone 14 通常性能较好）
2. 关闭不必要的应用释放内存
3. 重置模拟器：Device → Erase All Content and Settings

### 问题 2：真机调试问题
**症状**: 无法在真机上安装或运行应用

**检查清单**:
- [ ] 设备信任开发者证书
- [ ] Bundle Identifier 唯一
- [ ] 签名配置正确
- [ ] 设备 iOS 版本兼容

**签名配置**:
```swift
// 在项目设置中确认
Team: [你的 Apple Developer Team]
Code Sign Identity: Apple Development
Provisioning Profile: Automatic
```

### 问题 3：相机权限问题
**症状**: 拍照功能无法使用，权限被拒绝

**解决方案**:
1. 在 Info.plist 中添加权限描述：
```xml
<key>NSCameraUsageDescription</key>
<string>需要相机权限来拍照识别物品</string>
```

2. 在代码中检查权限状态：
```swift
import AVFoundation

let status = AVCaptureDevice.authorizationStatus(for: .video)
if status == .denied {
    // 引导用户到设置中开启权限
}
```

## 🔧 调试技巧

### 1. 使用断点调试
```swift
// 在代码中添加断点
let result = someFunction()
print("Debug: \(result)")  // 在此处设置断点
```

### 2. 查看控制台日志
```swift
// 添加详细的日志信息
print("📍 [文件名:第\(line)行] \(变量名) = \(变量值)")
debugPrint("详细调试信息: \(对象)")
```

### 3. 网络请求调试
```swift
// 检查网络请求状态
URLSession.shared.dataTask(with: request) { data, response, error in
    if let error = error {
        print("网络请求失败: \(error)")
        return
    }

    if let httpResponse = response as? HTTPURLResponse {
        print("响应状态码: \(httpResponse.statusCode)")
    }

    if let data = data {
        print("响应数据长度: \(data.count)")
    }
}
```

### 4. 内存调试
```swift
// 检查内存使用
class MemoryDebugger {
    static func logMemoryUsage() {
        let info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        if kerr == KERN_SUCCESS {
            let usedMB = Double(info.resident_size) / 1024.0 / 1024.0
            print("内存使用: \(String(format: "%.2f", usedMB)) MB")
        }
    }
}
```

## 🚨 常见运行时错误

### 1. "Unexpectedly found nil" 错误
**原因**: 强制解包了 nil 值

**预防措施**:
```swift
// ❌ 危险的强制解包
let text: String! = nil
print(text.count)  // 崩溃

// ✅ 安全的可选绑定
if let text = optionalText {
    print(text.count)
}

// ✅ 使用 nil-coalescing
let text = optionalText ?? "默认值"
```

### 2. "Index out of range" 错误
**原因**: 数组访问越界

**预防措施**:
```swift
// ❌ 可能越界
let item = array[index]

// ✅ 安全检查
guard index < array.count else {
    print("索引超出范围")
    return
}
let item = array[index]
```

### 3. "Thread 1: Signal SIGABRT" 错误
**常见原因**:
- Outlet 连接问题
- 违反 Auto Layout 约束
- 主线程更新 UI

**解决方案**:
```swift
// 确保在主线程更新 UI
DispatchQueue.main.async {
    self.someUIProperty = newValue
}
```

## 📊 性能优化

### 1. SwiftUI 性能优化
```swift
// 使用 @State 优化
@State private var items = [Item]()  // 而不是每次重新创建

// 懒加载
LazyVStack {
    ForEach(items) { item in
        ItemView(item: item)
    }
}

// 避免过度刷新
@StateObject private var viewModel = ContentViewModel()  // 而不是 @ObservedObject
```

### 2. 内存优化
```swift
// 及时释放大对象
@State private var largeImage: UIImage? = nil

// 在适当时候清理
func clearResources() {
    largeImage = nil
}

// 使用 weak 引用避免循环引用
class MyClass {
    weak var delegate: MyDelegate?
}
```

## 🔍 诊断工具和命令

### 有用的 Xcode 命令
```bash
# 查看项目设置
xcodebuild -showBuildSettings

# 清理构建产物
xcodebuild clean

# 分析项目
xcodebuild analyze

# 查看依赖树
pod tree
```

### 调试宏定义
```swift
// 在代码中添加调试开关
#if DEBUG
print("调试信息")
#endif

// 使用断言
assert(condition, "错误信息")
```

## 🆘 获取帮助

### 自助资源
1. **查看错误详情**: 点击 Xcode 中的红色错误标记
2. **搜索解决方案**: 使用错误信息作为关键词搜索
3. **查看文档**: 参考相关模块的 README 文档

### 寻求帮助时的信息准备
1. **错误信息**: 完整的错误日志
2. **重现步骤**: 详细说明如何触发问题
3. **环境信息**: Xcode 版本、iOS 版本、设备型号
4. **相关代码**: 问题相关的代码片段

### 有效的求助信息模板
```
问题描述：[简洁描述问题]
重现步骤：
1. 打开应用
2. 点击 [某个按钮]
3. 出现 [错误现象]

期望结果：[描述正确的行为]
实际结果：[描述实际发生的情况]

环境信息：
- Xcode 版本：[版本号]
- iOS 版本：[版本号]
- 设备型号：[设备名称]

相关代码：
[贴出关键代码片段]

错误日志：
[贴出完整的错误信息]
```

---

**提示**: 良好的调试习惯和详细的问题描述能够大大提高问题解决效率。遇到问题时不要慌张，系统性地排查通常能找到解决方案。
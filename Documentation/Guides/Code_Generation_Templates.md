# 代码生成模板

本文档提供了 HackWeek 项目中常用功能的代码模板，可以直接复制使用或提供给 AI 工具作为生成基础。

## 🏗️ 页面组件模板

### 基础页面模板
```swift
//
//  [PageName].swift
//  HackWeek
//
//  Created by [Author] on [Date].
//

import SwiftUI

/// [页面功能描述]
struct [PageName]: ComposablePageComponent {
    // MARK: - ComposablePageComponent Protocol

    /// 页面配置属性
    struct Props {
        let [属性名]: [类型]
        let [回调函数名]: () -> Void
    }

    let props: Props
    var pageName: String { "[page_name]" }

    var pageTrackingParams: [String: Any]? {
        [
            .TRACK_KEY_FROM: "[来源页面]",
            .TRACK_KEY_TYPE: "[页面类型]"
        ]
    }

    // MARK: - State Variables

    @State private var [状态变量]: [类型] = [默认值]
    @StateObject private var [ViewModel名] = [ViewModel实例]

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 页面头部
                    headerView

                    // 主要内容
                    contentView

                    // 底部操作
                    actionView
                }
                .padding()
            }
            .navigationTitle("[页面标题]")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("[操作按钮]") {
                        [操作逻辑]
                    }
                }
            }
        }
        .connect(viewModel: [ViewModel名])
    }
}

// MARK: - View Components

extension [PageName] {
    private var headerView: some View {
        VStack(spacing: 16) {
            Text("[标题]")
                .font(.title)
                .fontWeight(.bold)

            Text("[副标题或描述]")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var contentView: some View {
        VStack(spacing: 16) {
            // 主要内容区域
        }
    }

    private var actionView: some View {
        VStack(spacing: 12) {
            Button(action: {
                // 主要操作
            }) {
                Text("[按钮文字]")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(25)
            }

            if [显示次要操作的条件] {
                Button("[次要操作文字]") {
                    // 次要操作
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    [PageName](props: [PageName].Props(
        [属性名]: [默认值],
        [回调函数名]: { print("Action tapped") }
    ))
}
```

### 列表页面模板
```swift
//
//  [ListPageName].swift
//  HackWeek
//
//  Created by [Author] on [Date].
//

import SwiftUI
import SwiftData

/// [列表页面功能描述]
struct [ListPageName]: ComposablePageComponent {
    struct Props {
        let [属性名]: [类型]
        let onItemTap: ([ItemType]) -> Void
    }

    let props: Props
    var pageName: String { "[list_page_name]" }

    var pageTrackingParams: [String: Any]? {
        [.TRACK_KEY_TYPE: "list_view"]
    }

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext

    // MARK: - State Variables

    @State private var items: [[ItemType]] = []
    @State private var isLoading = false
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil

    // MARK: - Computed Properties

    private var filteredItems: [[ItemType]] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { item in
                // 搜索过滤逻辑
                return item.[搜索字段].localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                if [需要搜索功能] {
                    searchBar
                }

                // 分类选择器
                if [需要分类功能] {
                    categorySelector
                }

                // 列表内容
                if isLoading {
                    loadingView
                } else if filteredItems.isEmpty {
                    emptyStateView
                } else {
                    listView
                }
            }
            .navigationTitle("[列表标题]")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // 添加新项目
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                loadData()
            }
            .refreshable {
                await refreshData()
            }
        }
    }
}

// MARK: - View Components

extension [ListPageName] {
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("搜索...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach([分类数组], id: \.self) { category in
                    Button(category) {
                        selectedCategory = category == selectedCategory ? nil : category
                    }
                    .font(.subheadline)
                    .foregroundColor(selectedCategory == category ? .white : .blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(selectedCategory == category ? Color.blue : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    private var listView: some View {
        List(filteredItems, id: \.id) { item in
            Button(action: {
                props.onItemTap(item)
            }) {
                ItemRowView(item: item)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .listStyle(PlainListStyle())
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("加载中...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "[空状态图标]")
                .font(.system(size: 50))
                .foregroundColor(.secondary)

            Text("[空状态标题]")
                .font(.headline)
                .foregroundColor(.primary)

            Text("[空状态描述]")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Item Row View

struct ItemRowView: View {
    let item: [ItemType]

    var body: some View {
        HStack(spacing: 12) {
            // 左侧图标或图片
            if let [图片字段] = item.[图片字段] {
                Image(uiImage: [图片字段])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "[默认图标]")
                            .foregroundColor(.secondary)
                    )
            }

            // 中间内容
            VStack(alignment: .leading, spacing: 4) {
                Text(item.[标题字段])
                    .font(.headline)
                    .lineLimit(1)

                Text(item.[描述字段])
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            // 右侧信息
            VStack(alignment: .trailing, spacing: 4) {
                Text([附加信息])
                    .font(.caption)
                    .foregroundColor(.secondary)

                if [需要显示状态] {
                    Text("[状态信息]")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.[状态颜色].opacity(0.2))
                        .foregroundColor(Color.[状态颜色])
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Data Loading

extension [ListPageName] {
    private func loadData() {
        isLoading = true

        Task { @MainActor in
            do {
                // 加载数据逻辑
                items = try await [加载数据的方法]()
            } catch {
                print("加载数据失败: \(error)")
                // 显示错误提示
            }
            isLoading = false
        }
    }

    private func refreshData() async {
        // 刷新数据逻辑
        await loadData()
    }
}

// MARK: - Preview

#Preview {
    [ListPageName](props: [ListPageName].Props(
        [属性名]: [默认值],
        onItemTap: { item in
            print("Item tapped: \(item)")
        }
    ))
    .modelContainer(for: [DataType].self, inMemory: true)
}
```

## 💾 数据模型模板

### 基础数据模型
```swift
//
//  [ModelName].swift
//  HackWeek
//
//  Created by [Author] on [Date].
//

import Foundation
import SwiftData

/// [模型功能描述]
@Model
final class [ModelName] {
    // MARK: - Core Properties

    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Business Properties

    /// [字段描述]
    var [字段名]: [类型]

    /// [字段描述]
    var [字段名]: [类型]

    /// [字段描述]
    var [字段名]: [类型]?

    // MARK: - Relationships

    @Relationship(deleteRule: .cascade)
    var [关联数组]: [[关联模型类型]] = []

    @Relationship(inverse: \[反向关联模型].[关联字段])
    var [关联对象]: [关联模型类型]?

    // MARK: - Computed Properties

    var [计算属性名]: [返回类型] {
        // 计算逻辑
        return [计算结果]
    }

    // MARK: - Initialization

    init([参数列表]) {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()

        // 初始化属性
        self.[字段名] = [参数值]
        self.[字段名] = [参数值]
        self.[字段名] = [参数值]
    }

    // MARK: - Methods

    /// 更新数据
    func update([参数列表]) {
        self.[字段名] = [新值]
        self.[字段名] = [新值]
        self.updatedAt = Date()
    }

    /// 添加关联项
    func addRelatedItem(_ item: [关联模型类型]) {
        self.[关联数组].append(item)
    }

    /// 移除关联项
    func removeRelatedItem(_ item: [关联模型类型]) {
        self.[关联数组].removeAll { $0.id == item.id }
    }
}

// MARK: - Extensions

extension [ModelName] {
    /// 格式化日期显示
    var formattedCreatedAt: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }

    /// 检查是否为最新
    var isRecent: Bool {
        let daysSinceCreation = Calendar.current.dateComponents([.day],
                                                                from: createdAt,
                                                                to: Date()).day ?? 0
        return daysSinceCreation <= 7
    }
}

// MARK: - Sample Data

extension [ModelName] {
    /// 创建示例数据
    static let sample: [ModelName] = [
        [ModelName]([参数列表]),
        [ModelName]([参数列表]),
        [ModelName]([参数列表])
    ]
}
```

## 🧠 ViewModel 模板

### 基础 ViewModel
```swift
//
//  [ViewModelName].swift
//  HackWeek
//
//  Created by [Author] on [Date].
//

import Foundation
import SwiftUI
import SwiftData

/// [ViewModel 功能描述]
@MainActor
class [ViewModelName]: ComposableViewModel {

    // MARK: - Published Properties

    @Published var [状态变量]: [类型] = [默认值]
    @Published var [状态变量]: [类型] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let modelContext: ModelContext
    private let [其他依赖]: [依赖类型]

    // MARK: - Initialization

    init(modelContext: ModelContext, [其他依赖]: [依赖类型]) {
        self.modelContext = modelContext
        self.[其他依赖] = [其他依赖]
        super.init()

        loadData()
    }

    // MARK: - Public Methods

    /// 加载数据
    func loadData() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let result = try await [异步获取数据方法]()
                await MainActor.run {
                    self.[状态变量] = result
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "加载数据失败: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }

    /// 执行主要操作
    func performAction([参数列表]) async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await [异步操作方法](参数列表)
            await MainActor.run {
                // 处理结果
                self.handleActionResult(result)
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "操作失败: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    /// 删除项目
    func deleteItem(_ item: [ItemType]) {
        do {
            modelContext.delete(item)
            try modelContext.save()

            // 更新本地状态
            [状态变量].removeAll { $0.id == item.id }
        } catch {
            errorMessage = "删除失败: \(error.localizedDescription)"
        }
    }

    /// 刷新数据
    func refresh() {
        loadData()
    }

    /// 清除错误
    func clearError() {
        errorMessage = nil
    }

    // MARK: - Private Methods

    private func handleActionResult(_ result: [结果类型]) {
        // 处理操作结果的逻辑
        switch result {
        case .success(let data):
            // 成功处理
            [状态变量].append(data)
        case .failure(let error):
            // 失败处理
            errorMessage = error.localizedDescription
        }
    }

    private func [异步获取数据方法]() async throws -> [结果类型] {
        // 具体的数据获取逻辑
        let descriptor = FetchDescriptor<[数据模型类型]>(
            sortBy: [SortDescriptor(\.[排序字段], order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    private func [异步操作方法](_ [参数名]: [参数类型]) async throws -> [结果类型] {
        // 具体的操作逻辑
        let newItem = [数据模型类型]([参数列表])
        modelContext.insert(newItem)
        try modelContext.save()
        return newItem
    }
}

// MARK: - Result Types

enum [操作结果类型] {
    case success([成功数据类型])
    case failure(Error)
}
```

## 🔧 功能集成模板

### 拍照功能集成
```swift
// 在现有页面中添加拍照功能

import SwiftUI
import PhotosUI

struct [PageName]WithCamera: ComposablePageComponent {
    @State private var selectedImage: UIImage?
    @State private var isShowingCamera = false
    @State private var isShowingImagePicker = false
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack {
            // 图片预览
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "camera")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            Text("添加图片")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    )
            }

            // 图片选择按钮
            HStack(spacing: 12) {
                Button("拍照") {
                    isShowingCamera = true
                }
                .buttonStyle(.borderedProminent)

                Button("从相册选择") {
                    isShowingImagePicker = true
                }
                .buttonStyle(.bordered)

                if selectedImage != nil {
                    Button("删除图片") {
                        selectedImage = nil
                    }
                    .foregroundColor(.red)
                }
            }
            .padding(.top)
        }
        .sheet(isPresented: $isShowingCamera) {
            TemplateAPI.Navigator.present(
                CameraPage { image in
                    selectedImage = image
                    isShowingCamera = false
                },
                from: "[当前页面名]",
                animated: true
            )
        }
        .sheet(isPresented: $isShowingImagePicker) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Text("选择图片")
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                    }
                }
            }
        }
    }
}
```

### AI 功能集成
```swift
// AI 功能集成模板

import SwiftUI

struct [PageName]WithAI: ComposablePageComponent {
    @State private var inputText = ""
    @State private var aiResponse = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            // 输入区域
            VStack(alignment: .leading, spacing: 8) {
                Text("输入内容")
                    .font(.headline)

                TextField("请输入...", text: $inputText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }

            // 发送按钮
            Button(action: {
                Task {
                    await generateAIResponse()
                }
            }) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text("发送")
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(inputText.isEmpty || isLoading ? Color.gray : Color.blue)
                .cornerRadius(22)
            }
            .disabled(inputText.isEmpty || isLoading)

            // 响应区域
            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("AI 正在思考...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else if !aiResponse.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("AI 回复")
                        .font(.headline)

                    Text(aiResponse)
                        .font(.body)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
            }

            // 错误显示
            if let errorMessage = errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
    }

    private func generateAIResponse() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await TemplateAPI.ChatGPT.sendMessage(
                inputText,
                systemPrompt: "你是一个有用的助手，请简洁地回答用户的问题。"
            )

            await MainActor.run {
                aiResponse = response
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "请求失败: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}
```

## 🎨 UI 组件模板

### 表单组件
```swift
struct FormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let isSecure: Bool

    init(title: String, text: Binding<String>, placeholder: String = "", isSecure: Bool = false) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.isSecure = isSecure
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: text)
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

// 使用示例
struct RegistrationForm: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 20) {
            FormField(title: "用户名", text: $username, placeholder: "请输入用户名")
            FormField(title: "邮箱", text: $email, placeholder: "请输入邮箱地址")
            FormField(title: "密码", text: $password, placeholder: "请输入密码", isSecure: true)
        }
        .padding()
    }
}
```

### 状态指示器
```swift
struct StatusIndicator: View {
    let status: Status
    let message: String

    enum Status {
        case success, warning, error, info

        var color: Color {
            switch self {
            case .success: return .green
            case .warning: return .orange
            case .error: return .red
            case .info: return .blue
            }
        }

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: status.icon)
                .foregroundColor(status.color)
                .font(.title3)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()
        }
        .padding()
        .background(status.color.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(status.color.opacity(0.3), lineWidth: 1)
        )
    }
}

// 使用示例
struct StatusExample: View {
    var body: some View {
        VStack(spacing: 12) {
            StatusIndicator(status: .success, message: "操作成功完成")
            StatusIndicator(status: .warning, message: "请注意检查设置")
            StatusIndicator(status: .error, message: "网络连接失败")
            StatusIndicator(status: .info, message: "数据正在同步中")
        }
        .padding()
    }
}
```

## 🔍 测试模板

### 单元测试模板
```swift
//
//  [TestName].swift
//  HackWeekTests
//
//  Created by [Author] on [Date].
//

import XCTest
import SwiftData
@testable import HackWeek

final class [TestName]: XCTestCase {

    // MARK: - Test Properties

    var modelContext: ModelContext!
    var systemUnderTest: [被测试的类名]!

    // MARK: - Test Lifecycle

    override func setUpWithError() throws {
        try super.setUpWithError()

        // 设置测试环境
        let schema = Schema([相关数据模型类型.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(container)

        // 初始化被测试的对象
        systemUnderTest = [被测试的类名](modelContext: modelContext)
    }

    override func tearDownWithError() throws {
        systemUnderTest = nil
        modelContext = nil
        try super.tearDownWithError()
    }

    // MARK: - Test Cases

    func testInitialization() throws {
        // 测试初始化
        XCTAssertNotNil(systemUnderTest)
        // 添加其他初始化断言
    }

    func testLoadData() async throws {
        // 测试数据加载
        await systemUnderTest.loadData()

        // 验证加载结果
        XCTAssertFalse(systemUnderTest.isLoading)
        XCTAssertNotNil(systemUnderTest.[数据属性])
        // 添加其他断言
    }

    func testPerformAction() async throws {
        // 测试主要操作
        let expectation = XCTestExpectation(description: "操作完成")

        await systemUnderTest.performAction([测试参数])

        // 验证操作结果
        XCTAssertFalse(systemUnderTest.isLoading)
        XCTAssertNil(systemUnderTest.errorMessage)
        // 添加其他断言

        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 5.0)
    }

    func testErrorHandling() async throws {
        // 测试错误处理
        // 模拟错误条件
        // 执行操作
        // 验证错误处理
    }

    func testDeleteItem() throws {
        // 测试删除功能
        let item = [创建测试数据]()
        modelContext.insert(item)
        try modelContext.save()

        // 确认数据存在
        var items = try modelContext.fetch(FetchDescriptor<[数据模型类型]>())
        XCTAssertEqual(items.count, 1)

        // 执行删除
        systemUnderTest.deleteItem(item)

        // 验证删除结果
        items = try modelContext.fetch(FetchDescriptor<[数据模型类型]>())
        XCTAssertEqual(items.count, 0)
    }
}
```

## 💡 使用说明

### 如何使用这些模板

1. **复制模板**: 选择需要的模板，复制到你的项目中
2. **替换占位符**: 将 `[占位符]` 替换为实际的名称和类型
3. **自定义调整**: 根据具体需求调整代码
4. **集成到项目**: 确保与现有代码正确集成

### 提供给 AI 工具的提示词

```
请使用以下 HackWeek 代码模板来生成 [功能描述]：

[粘贴相应的模板代码]

要求：
1. 将所有 [占位符] 替换为合适的名称
2. 根据功能需求调整代码结构
3. 确保代码符合 HackWeek 架构规范
4. 添加必要的注释和文档
5. 考虑错误处理和边界情况
```

---

**提示**: 这些模板提供了标准化的代码结构，可以大大提高开发效率和代码质量。根据具体项目需求进行适当调整。
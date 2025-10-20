# 拍照功能使用指南

## 概述

HackWeek 模板提供了完整的拍照功能集成，包括相机权限管理、实时预览、拍照控制和图片处理等功能。该功能展示了如何将企业级相机能力集成到 SwiftUI 应用中。

## 核心特性

- ✅ **相机权限管理**: 自动请求和处理相机权限
- ✅ **实时预览**: 相机画面实时显示
- ✅ **拍照控制**: 拍照、切换相机、闪光灯控制
- ✅ **图片处理**: VisionKit 抠图、图片压缩和优化
- ✅ **错误处理**: 完善的错误处理和用户提示
- ✅ **企业级集成**: 与 GLCamera 库深度集成

## 快速开始

### 基本使用

```swift
import SwiftUI

struct CameraDemo: View {
    @State private var showCamera = false

    var body: some View {
        VStack {
            Text("拍照演示")

            Button("打开相机") {
                showCamera = true
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPage()
        }
    }
}
```

### 导航集成

```swift
// 使用 Navigator 打开相机
Navigator.present(CameraPage(), from: "current_page")
```

## 核心组件详解

### 1. CameraPage (相机界面)

#### 职责
- 提供完整的相机拍摄界面
- 管理相机预览和用户交互
- 处理拍照结果和错误状态

#### 核心实现
```swift
struct CameraPage: View {
    @StateObject private var viewModel = CameraViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // 相机预览
            CameraPreview(session: viewModel.session)
                .ignoresSafeArea()

            // 控制界面
            VStack {
                Spacer()

                // 底部控制栏
                HStack {
                    // 闪光灯控制
                    FlashButton(isOn: $viewModel.isFlashOn) {
                        viewModel.toggleFlash()
                    }

                    Spacer()

                    // 拍照按钮
                    CameraButton {
                        viewModel.capturePhoto()
                    }

                    Spacer()

                    // 切换相机
                    SwitchCameraButton {
                        viewModel.switchCamera()
                    }
                }
                .padding()
                .background(Color.black.opacity(0.7))
            }
        }
        .onAppear {
            viewModel.setupCamera()
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
}
```

### 2. CameraViewModel (业务逻辑)

#### 职责
- 管理相机会话和配置
- 处理拍照流程
- 管理相机状态和权限

#### 核心接口
```swift
@MainActor
class CameraViewModel: ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var isFlashOn = false
    @Published var isInitialized = false
    @Published var errorMessage: String?
    @Published var capturedImage: UIImage?

    // 设置相机
    func setupCamera()

    // 拍照
    func capturePhoto()

    // 切换闪光灯
    func toggleFlash()

    // 切换相机
    func switchCamera()

    // 清理资源
    func cleanup()
}
```

## 详细使用指南

### 1. 权限配置

#### Info.plist 配置
```xml
<key>NSCameraUsageDescription</key>
<string>此应用需要访问相机来拍摄和识别图片内容</string>
```

#### 权限检查
```swift
import AVFoundation

class CameraPermissionManager {
    static func checkCameraPermission() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }

    static func requestCameraPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
```

### 2. 相机配置

#### 会话配置
```swift
private func setupCameraSession() {
    // 配置输入设备
    guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
          let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
        showError("无法访问相机")
        return
    }

    // 配置输出
    let photoOutput = AVCapturePhotoOutput()
    photoOutput.isHighResolutionCaptureEnabled = true

    // 添加到会话
    session.beginConfiguration()
    if session.canAddInput(videoInput) {
        session.addInput(videoInput)
    }
    if session.canAddOutput(photoOutput) {
        session.addOutput(photoOutput)
    }
    session.commitConfiguration()

    // 配置输出设置
    if let connection = photoOutput.connection(with: .video) {
        if connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
        }
        if connection.isVideoStabilizationSupported {
            connection.preferredVideoStabilizationMode = .auto
        }
    }
}
```

### 3. 拍照实现

#### 基本拍照
```swift
func capturePhoto() {
    guard let photoOutput = photoOutput else { return }

    let settings = AVCapturePhotoSettings()

    // 闪光灯设置
    if isFlashOn, device?.hasFlash == true {
        settings.flashMode = .on
    } else {
        settings.flashMode = .off
    }

    // 高质量设置
    settings.isHighResolutionPhotoEnabled = true

    photoOutput.capturePhoto(with: settings, delegate: self)
}
```

#### 拍照结果处理
```swift
extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            errorMessage = "拍照失败: \(error.localizedDescription)"
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            errorMessage = "无法处理照片"
            return
        }

        // 保存拍摄的图片
        capturedImage = image

        // 处理图片（压缩、优化等）
        processImage(image)
    }
}
```

### 4. 图片处理

#### 图片压缩和优化
```swift
private func processImage(_ image: UIImage) -> UIImage? {
    // 压缩图片到合适尺寸
    let maxSize: CGFloat = 1024
    let scale = min(maxSize / image.size.width, maxSize / image.size.height)

    let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image.draw(in: CGRect(origin: .zero, size: newSize))
    let processedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return processedImage
}
```

#### 图片质量优化
```swift
private func optimizeImageForUpload(_ image: UIImage) -> Data? {
    // JPEG 压缩，平衡质量和文件大小
    let compressionQuality: CGFloat = 0.8
    return image.jpegData(compressionQuality: compressionQuality)
}
```

### 5. 错误处理

#### 常见错误类型
```swift
enum CameraError: LocalizedError {
    case permissionDenied
    case deviceNotAvailable
    case configurationFailed
    case captureFailed(String)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "相机权限被拒绝，请在设置中允许访问相机"
        case .deviceNotAvailable:
            return "相机设备不可用"
        case .configurationFailed:
            return "相机配置失败"
        case .captureFailed(let message):
            return "拍照失败: \(message)"
        }
    }
}
```

#### 错误处理实现
```swift
private func handleCameraError(_ error: Error) {
    DispatchQueue.main.async {
        if let cameraError = error as? CameraError {
            self.errorMessage = cameraError.localizedDescription
        } else {
            self.errorMessage = "相机错误: \(error.localizedDescription)"
        }
    }
}
```

## 实际应用场景

### 1. WordBook 中的拍照功能

```swift
// WordBook 中的相机集成
struct WordBookCameraView: View {
    @StateObject private var cameraViewModel = CameraViewModel()

    var body: some View {
        ZStack {
            // 相机预览
            CameraPageView(viewModel: cameraViewModel)

            // 拍照后的处理
            if let capturedImage = cameraViewModel.capturedImage {
                NavigationLink(
                    destination: IdentificationPage(image: capturedImage),
                    isActive: .constant(true),
                    label: { EmptyView() }
                )
            }
        }
    }
}
```

### 2. 自定义拍照界面

```swift
struct CustomCameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    @State private var showFilters = false

    var body: some View {
        ZStack {
            // 相机预览
            CameraPreview(session: viewModel.session)
                .overlay(
                    // 滤镜预览
                    Color.clear.overlay(
                        Rectangle().fill(selectedFilter.color).opacity(0.3)
                    )
                )

            // 自定义控制界面
            VStack {
                // 顶部工具栏
                HStack {
                    Button("取消") {
                        // 关闭相机
                    }

                    Spacer()

                    Button("滤镜") {
                        showFilters.toggle()
                    }
                }
                .padding()
                .background(Color.black.opacity(0.5))

                Spacer()

                // 底部控制栏
                CustomCameraControls(viewModel: viewModel)
            }
        }
        .sheet(isPresented: $showFilters) {
            FilterSelectionView(selectedFilter: $selectedFilter)
        }
    }
}
```

### 3. 拍照后处理流程

```swift
class PhotoProcessingManager {
    static func processPhoto(_ image: UIImage) async throws -> ProcessedImage {
        // 1. 图片预处理
        let preprocessedImage = try await preprocessImage(image)

        // 2. VisionKit 抠图 (iOS 17+)
        let segmentedImage = try await performSegmentation(preprocessedImage)

        // 3. 上传到 S3
        let imageUrl = try await uploadToS3(segmentedImage)

        // 4. LLM 识别
        let recognizedText = try await recognizeImage(imageUrl)

        return ProcessedImage(
            original: image,
            processed: segmentedImage,
            url: imageUrl,
            recognizedText: recognizedText
        )
    }
}
```

## 高级功能

### 1. VisionKit 抠图集成

```swift
import VisionKit

@available(iOS 17.0, *)
func performSubjectSegmentation(_ image: UIImage) async throws -> UIImage {
    let request = VNGenerateForegroundInstanceMaskRequest()

    guard let cgImage = image.cgImage else {
        throw CameraError.configurationFailed
    }

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    try handler.perform([request])

    guard let result = request.results?.first as? VNInstanceMaskObservation else {
        throw CameraError.captureFailed("无法抠图")
    }

    // 创建抠图后的图片
    let maskedImage = try createMaskedImage(from: result, originalImage: cgImage)
    return maskedImage
}
```

### 2. 实时滤镜效果

```swift
class FilterManager: ObservableObject {
    @Published var currentFilter: FilterType = .none
    @Published var isProcessing = false

    enum FilterType {
        case none, vintage, blackWhite, warm, cool

        var color: Color {
            switch self {
            case .none: return .clear
            case .vintage: return .brown.opacity(0.3)
            case .blackWhite: return .gray.opacity(0.5)
            case .warm: return .orange.opacity(0.2)
            case .cool: return .blue.opacity(0.2)
            }
        }
    }

    func applyFilter(_ image: UIImage, filter: FilterType) async -> UIImage? {
        isProcessing = true
        defer { isProcessing = false }

        // 应用滤镜逻辑
        return await processFilter(image, filter)
    }
}
```

### 3. 相机设置高级配置

```swift
extension CameraViewModel {
    func configureAdvancedSettings() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }

        do {
            try device.lockForConfiguration()

            // 设置对焦模式
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }

            // 设置曝光模式
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }

            // 设置白平衡
            if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                device.whiteBalanceMode = .continuousAutoWhiteBalance
            }

            device.unlockForConfiguration()
        } catch {
            errorMessage = "相机配置失败: \(error.localizedDescription)"
        }
    }
}
```

## 性能优化

### 1. 内存管理

```swift
class CameraViewModel: ObservableObject {
    private var currentPhotoData: Data?

    deinit {
        cleanup()
    }

    func cleanup() {
        session.stopRunning()
        currentPhotoData = nil
        capturedImage = nil
    }
}
```

### 2. 图片处理优化

```swift
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func compressed(maxSizeKB: Int = 500) -> Data? {
        var compression: CGFloat = 1.0
        var imageData = self.jpegData(compressionQuality: compression)

        while let data = imageData, data.count / 1024 > maxSizeKB && compression > 0.1 {
            compression -= 0.1
            imageData = self.jpegData(compressionQuality: compression)
        }

        return imageData
    }
}
```

### 3. 异步处理

```swift
@MainActor
class CameraViewModel: ObservableObject {
    func capturePhotoAsync() async {
        do {
            let image = try await capturePhoto()

            // 在后台线程处理图片
            let processedImage = await Task.detached {
                return self.processImage(image)
            }.value

            // 回到主线程更新 UI
            self.capturedImage = processedImage

        } catch {
            errorMessage = "拍照失败: \(error.localizedDescription)"
        }
    }
}
```

## 测试策略

### 单元测试

```swift
import XCTest
@testable import YourApp

class CameraViewModelTests: XCTestCase {
    var viewModel: CameraViewModel!

    override func setUp() {
        super.setUp()
        viewModel = CameraViewModel()
    }

    func testCameraSetup() {
        // 测试相机初始化
        viewModel.setupCamera()

        // 验证会话状态
        XCTAssertNotNil(viewModel.session)
        XCTAssertTrue(viewModel.isInitialized)
    }

    func testFlashToggle() {
        // 测试闪光灯切换
        let initialFlashState = viewModel.isFlashOn
        viewModel.toggleFlash()
        XCTAssertEqual(viewModel.isFlashOn, !initialFlashState)
    }
}
```

### UI 测试

```swift
import XCTest

class CameraUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }

    func testCameraCapture() {
        // 打开相机
        app.buttons["Open Camera"].tap()

        // 等待相机加载
        let cameraPreview = app.otherElements["Camera Preview"]
        XCTAssertTrue(cameraPreview.waitForExistence(timeout: 5))

        // 拍照
        app.buttons["Capture Button"].tap()

        // 验证拍照结果
        let capturedImage = app.images["Captured Image"]
        XCTAssertTrue(capturedImage.waitForExistence(timeout: 3))
    }
}
```

## 常见问题

### Q: 如何处理相机权限被拒绝的情况？
A: 在 CameraViewModel 中实现权限检查逻辑，并提供引导用户到设置页面的功能：

```swift
func checkCameraPermission() {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
        setupCamera()
    case .denied, .restricted:
        showPermissionDeniedAlert()
    case .notDetermined:
        requestCameraPermission()
    @unknown default:
        break
    }
}
```

### Q: 如何优化大图片的处理性能？
A: 使用后台队列处理图片，合理压缩图片尺寸，及时释放内存：

```swift
DispatchQueue.global(qos: .userInitiated).async {
    let processedImage = self.processLargeImage(image)

    DispatchQueue.main.async {
        self.capturedImage = processedImage
    }
}
```

### Q: 如何支持不同的拍照模式？
A: 扩展 CameraViewModel，添加拍照模式配置：

```swift
enum CameraMode {
    case standard, portrait, night, panorama
}

@Published var cameraMode: CameraMode = .standard

func configureForMode(_ mode: CameraMode) {
    // 根据模式配置相机设置
}
```

### Q: 如何处理拍照失败的情况？
A: 实现完善的错误处理机制，提供用户友好的错误提示和重试选项：

```swift
func handleCaptureError(_ error: Error) {
    let retryAction = UIAlertAction(title: "重试", style: .default) { _ in
        self.capturePhoto()
    }

    showAlert(title: "拍照失败", message: error.localizedDescription, actions: [retryAction])
}
```

---

*拍照功能为 HackWeek 提供了完整的相机集成能力，展示了企业级相机功能的最佳实践。*
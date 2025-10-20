//
//  CameraPage.swift
//  HackWords
//
//  Created by Claude on 2025/10/13.
//

import SwiftUI
import UIKit

/// 相机页面Props
struct CameraPageProps {
    var onImageCaptured: ((UIImage) -> Void)?
    var onCancel: (() -> Void)?
}

/// 相机页面
struct CameraPage: ComposablePageComponent {
    // MARK: - ComposablePageComponent Protocol
    typealias ComponentProps = CameraPageProps

    let props: ComponentProps

    init(props: ComponentProps = CameraPageProps()) {
        self.props = props
    }

    var pageName: String { "camera_page" }

    var pageTrackingParams: [String: Any]? {
        [
            .TRACK_KEY_FROM: "main_app",
            .TRACK_KEY_TYPE: "camera"
        ]
    }

    // MARK: - State Variables
    @StateObject private var viewModel = CameraViewModel()

    var body: some View {
        CameraViewControllerWrapper(
            onImageSelected: { image in
                viewModel.processCapturedImage(image)
            },
            onCancel: {
                viewModel.handleCancel()
            }
        )
        .ignoresSafeArea()
        .alert("需要相机权限", isPresented: $viewModel.showingPermissionAlert) {
            Button("取消", role: .cancel) {
                props.onCancel?()
            }
            Button("设置") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        } message: {
            Text("请在设置中允许访问相机以使用此功能")
        }
        .onAppear {
            viewModel.checkCameraPermission()
        }
    }
}

// UIViewController 相机包装器
struct CameraViewControllerWrapper: UIViewControllerRepresentable {
    let onImageSelected: (UIImage) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        picker.modalPresentationStyle = .fullScreen
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImageSelected: onImageSelected, onCancel: onCancel)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImageSelected: (UIImage) -> Void
        let onCancel: () -> Void

        init(onImageSelected: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
            self.onImageSelected = onImageSelected
            self.onCancel = onCancel
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                onImageSelected(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            onCancel()
        }
    }
}

#Preview {
    CameraPage()
}

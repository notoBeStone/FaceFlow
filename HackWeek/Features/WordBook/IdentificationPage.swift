//
//  IdentificationPage.swift
//  HackWords
//
//  Created by Claude on 2025/10/13.
//

import SwiftUI

struct IdentificationPage: View, GLSwiftUIPageTrackable {
    let image: UIImage
    @StateObject private var viewModel: IdentificationViewModel

    init(image: UIImage) {
        self.image = image
        self._viewModel = StateObject(wrappedValue: IdentificationViewModel(image: image))
    }

    var trackerPageName: String? = "identification_page"
    var trackerPageParams: [String: Any]? = [:]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 上2/3展示照片处理
                GeometryReader { geometry in
                    ZStack {
                        Color.black.ignoresSafeArea()

                        if let currentImage = viewModel.currentImage {
                            Image(uiImage: currentImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                        }

                        // 处理中的覆盖层
                        if viewModel.isProcessing {
                            Color.black.opacity(0.3)
                                .ignoresSafeArea()

                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)

                                Text(viewModel.statusText)
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .padding(.top)
                            }
                        }
                    }
                }
                .frame(height: UIScreen.main.bounds.height * 2/3)

                Spacer()

                // 下1/3展示状态文案
                VStack(spacing: 20) {
                    Text(viewModel.statusText)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)

                    // 完成状态时显示操作按钮
                    if viewModel.currentState == .completed {
                        VStack(spacing: 16) {
                            Button(action: {
                                viewModel.saveToWordbook()
                                TemplateAPI.Navigator.pop()
                            }) {
                                Text("保存到单词本")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.blue)
                                    .cornerRadius(25)
                            }

                            Button(action: {
                                TemplateAPI.Navigator.pop()
                            }) {
                                Text("继续拍照")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(25)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .frame(height: UIScreen.main.bounds.height * 1/3)
                .padding()

                Spacer()
            }
            .navigationTitle("识别中")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        TemplateAPI.Navigator.pop()
                    }
                    .disabled(viewModel.isProcessing)
                }
            }
        }
        .onAppear {
            viewModel.startIdentification()
        }
    }

    func onFirstAppear() {
        debugPrint("Identification page appeared with image")
    }

    func onPageExit() {
        debugPrint("Identification page exited")
    }
}

#Preview {
    // 创建一个示例图片用于预览
    let sampleImage = UIImage(systemName: "photo") ?? UIImage()
    IdentificationPage(image: sampleImage)
}
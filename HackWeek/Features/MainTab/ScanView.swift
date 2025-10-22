//
//  ScanView.swift
//  HackWords
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI
import GLMP
import SwiftData

/// Scan 页面
struct ScanView: View {
    // MARK: - Environment
    
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - State
    
    @StateObject private var viewModel = ScanViewModel()
    @State private var showModeSheet = false
    @State private var showImagePicker = false
    @State private var selectedScanType: ScanType = .makeup
    @State private var capturedImage: UIImage?
    @State private var showAnalyzing = false
    @State private var selectedMakeupRecord: ScanRecord?
    @State private var selectedProductRecord: ScanRecord?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainBG
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // 妆容评分区域
                        makeupSection
                        
                        // 产品扫描区域
                        productSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100) // 为底部按钮留空间
                }
                
                // 底部拍照按钮
                VStack {
                    Spacer()
                    cameraButton
                        .padding(.bottom, 32)
                }
            }
            .navigationTitle(GLMPLanguage.scan_title)
            .sheet(isPresented: $showModeSheet) {
                CameraModeSheet { scanType in
                    selectedScanType = scanType
                    showImagePicker = true
                }
            }
            .sheet(isPresented: $showImagePicker) {
                // 模拟器不支持相机，使用相册
                let sourceType: UIImagePickerController.SourceType = {
                    #if targetEnvironment(simulator)
                    return .photoLibrary
                    #else
                    return UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
                    #endif
                }()
                
                ImagePicker(sourceType: sourceType) { image in
                    capturedImage = image
                    Task {
                        showAnalyzing = true
                        if let record = await viewModel.analyzeImage(image, scanType: selectedScanType, modelContext: modelContext) {
                            showAnalyzing = false
                            // 分析成功后自动打开详情页
                            if selectedScanType == .makeup {
                                selectedMakeupRecord = record
                            } else {
                                selectedProductRecord = record
                            }
                        } else {
                            showAnalyzing = false
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchRecords(modelContext: modelContext)
            }
            .fullScreenCover(isPresented: $showAnalyzing) {
                AIAnalysisLoadingView(scanType: selectedScanType)
            }
            .sheet(item: $selectedMakeupRecord) { record in
                MakeupResultView(record: record)
            }
            .sheet(item: $selectedProductRecord) { record in
                ProductResultView(record: record)
            }
            .alert(GLMPLanguage.scan_error_title, isPresented: $viewModel.showError) {
                Button(GLMPLanguage.scan_error_ok, role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    // MARK: - Views
    
    /// 妆容评分区域
    private var makeupSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(GLMPLanguage.scan_makeup_section_title)
                .font(.avenirTitle3Heavy)
                .foregroundColor(.g9L)
            
            if viewModel.makeupRecords.isEmpty {
                EmptySectionView(
                    icon: "face.smiling",
                    title: GLMPLanguage.scan_empty_makeup
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.makeupRecords) { record in
                            ScanRecordCard(record: record) {
                                selectedMakeupRecord = record
                            } onDelete: {
                                viewModel.deleteRecord(record, modelContext: modelContext)
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// 产品扫描区域
    private var productSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(GLMPLanguage.scan_product_section_title)
                .font(.avenirTitle3Heavy)
                .foregroundColor(.g9L)
            
            if viewModel.productRecords.isEmpty {
                EmptySectionView(
                    icon: "cube.box",
                    title: GLMPLanguage.scan_empty_product
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.productRecords) { record in
                            ScanRecordCard(record: record) {
                                selectedProductRecord = record
                            } onDelete: {
                                viewModel.deleteRecord(record, modelContext: modelContext)
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// 拍照按钮
    private var cameraButton: some View {
        Button(action: {
            showModeSheet = true
        }) {
            ZStack {
                Circle()
                    .fill(Color.mainColor)
                    .frame(width: 64, height: 64)
                    .shadow(color: Color.mainColor.opacity(0.4), radius: 12, x: 0, y: 4)
                
                Image(systemName: "camera.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Supporting Views

/// 空区域视图
private struct EmptySectionView: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.g4L)
            
            Text(title)
                .font(.avenirBodyRoman)
                .foregroundColor(.g6L)
            
            Text(GLMPLanguage.scan_start_analyzing)
                .font(.avenirCaptionRoman)
                .foregroundColor(.g5L)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .background(Color.gwL)
        .cornerRadius(16)
    }
}

/// 扫描记录卡片
private struct ScanRecordCard: View {
    let record: ScanRecord
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteConfirm = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // 图片
                if let image = record.thumbnailImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 160, height: 120)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    Rectangle()
                        .fill(Color.g2L)
                        .frame(width: 160, height: 120)
                        .cornerRadius(12)
                }
                
                // 评分或标题
                HStack {
                    if record.type == .makeup, let result = record.makeupResult {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.mainColor)
                            
                            Text(result.score)
                                .font(.avenirBodyHeavy)
                                .foregroundColor(.g9L)
                        }
                    } else if record.type == .product, let result = record.productResult {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                            
                            Text(result.score)
                                .font(.avenirBodyHeavy)
                                .foregroundColor(.g9L)
                        }
                    }
                    
                    Spacer()
                    
                    // 删除按钮
                    Button(action: {
                        showDeleteConfirm = true
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.g5L)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // 日期
                Text(record.formattedDate)
                    .font(.avenirCaptionRoman)
                    .foregroundColor(.g5L)
                    .lineLimit(1)
            }
            .frame(width: 160)
            .padding(12)
            .background(Color.gwL)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .confirmationDialog(
            GLMPLanguage.scan_delete_confirm_title,
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button(GLMPLanguage.scan_delete_confirm_yes, role: .destructive) {
                onDelete()
            }
            Button(GLMPLanguage.text_cancel, role: .cancel) {}
        } message: {
            Text(GLMPLanguage.scan_delete_confirm_message)
        }
    }
}

#Preview {
    ScanView()
        .modelContainer(for: ScanRecord.self)
}


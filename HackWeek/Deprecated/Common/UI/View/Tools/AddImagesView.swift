//
//  AddImagesView.swift
//  AINote
//
//  Created by user on 2024/8/13.
//

import SwiftUI
import UniformTypeIdentifiers
import AppModels
import GLMP
import GLUtils
import GLWebImage

struct AddImagesView_Preview: PreviewProvider {
    @State static var images: [ImageOrImageUrlAppModel] = []
    static var previews: some View {
        AddImagesView(images: $images, maxImageCount: 3)
    }
}

struct AddImagesView: View {

    @ObservedObject private var viewModel: AddImagesViewModel
    
    init(images: Binding<[ImageOrImageUrlAppModel]>, maxImageCount: Int) {
        self.viewModel = AddImagesViewModel(images: images, maxImageCount: maxImageCount)
    }
    
    //"Add Images (0/3)"
    var body: some View {
        VStack(alignment: .center, spacing: 16.rpx) {
            HStack(alignment: .center, spacing: 0) {
                Text(GLMPLanguage.text_add_images + "(\(viewModel.images.count)/\(viewModel.maxImageCount))")
                    .textStyle(.headlineBold)
                    .foregroundColor(.g9)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
            }
            .padding(.vertical, 2.rpx)
            .frame(maxWidth: .infinity)
            
            HStack {
                
                ForEach(viewModel.images.indices, id: \.self) { index in
                    AddImagesImageItemView(imageModel: viewModel.images[index]) {
                        viewModel.images.remove(at: index)
                    }
                }
                
                if viewModel.remainCount > 0 {
                    AddImagesAddItemView()
                        .onTapGesture {
                            debugPrint("click")
                            gl_endEditing()
                            viewModel.addImageClick()
                        }
                }
                
                Spacer()
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 106.rpx)
        }
        .padding(.horizontal, 16.rpx)
        .padding(.vertical, 16.rpx)
        .frame(maxWidth: .infinity)
    }
    
}

struct AddImagesImageItemView: View {
    let imageModel: ImageOrImageUrlAppModel
    let onDelete: () -> Void
    
    var body: some View {
        if let imageUrl = imageModel.imageUrl {
            GLImage(imageUrl, minLength: 106)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 106.rpx, height: 106.rpx)
                .cornerRadius(8.rpx)
                .overlay(
                    ZStack(alignment: .topTrailing) {
                        Color.clear
                        
                        Rectangle()
                            .foregroundColor(.clear)
                            .background(
                                Image("common_close_20")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 20.rpx, height: 20.rpx)
                            )
                            .frame(width: 44.rpx, height: 44.rpx)
                            .offset(x: 16.rpx, y: -16.rpx)
                            .onTapGesture {
                                onDelete()
                            }
                    }
                )
        }
        
        if let image = imageModel.image {
            Rectangle()
                .foregroundColor(.clear)
                .background(
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 106.rpx, height: 106.rpx)
                )
                .frame(width: 106.rpx, height: 106.rpx)
                .cornerRadius(8.rpx)
                .overlay(
                    ZStack(alignment: .topTrailing) {
                        Color.clear
                        
                        Rectangle()
                            .foregroundColor(.clear)
                            .background(
                                Image("common_close_20")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 20.rpx, height: 20.rpx)
                            )
                            .frame(width: 44.rpx, height: 44.rpx)
                            .offset(x: 16.rpx, y: -16.rpx)
                            .onTapGesture {
                                onDelete()
                            }
                    }
                )
        }

    }
}

struct AddImagesAddItemView: View {
    var body: some View {
        Rectangle()
            .foregroundColor(.g1N)
            .overlay(
                Image("icon_add_outlined_heavy")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(.g6)
                    .frame(width: 24.rpx, height: 24.rpx)
            )
            .cornerRadius(8.rpx)
            .frame(width: 106.rpx, height: 106.rpx)
    }
}


fileprivate class AddImagesViewModel: NSObject, ObservableObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @Binding var images: [ImageOrImageUrlAppModel]
    
    let maxImageCount: Int
    
    var remainCount: UInt {
        return maxImageCount - images.count > 0 ? UInt(maxImageCount - images.count) : 0
    }
    
    init(images: Binding<[ImageOrImageUrlAppModel]>, maxImageCount: Int = 3) {
        self._images = images
        self.maxImageCount = maxImageCount
    }
    
    func addImageClick() {
        let takePhotoModel = GLAlertButtonModel(title: GLMPLanguage.text_take_photo, style: .default)
        let albumModel = GLAlertButtonModel(title: GLMPLanguage.text_select_from_photos, style: .default)
        let cancelModel = GLAlertButtonModel(title: GLMPLanguage.text_cancel, style: .cancel)
        
        UIAlertController.gl_sheetController(with: [takePhotoModel, albumModel, cancelModel]) { [weak self] controller, buttonIndex in
            guard let self = self else { return }
            if buttonIndex == 0 { //拍照
                GLMPPermission.requestCameraPermission {[weak self] granted in
                    if granted {
                        self?.takePhotoFramCamera()
                    }
                }
            } else if buttonIndex == 1 { //相册
                self.selectImageFromAlbum()
            } else{
                //取消
            }
        }
    }
    
    private func takePhotoFramCamera() {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        imagePickerVC.mediaTypes = [UTType.image.identifier]
        imagePickerVC.allowsEditing = false
        imagePickerVC.sourceType = .camera
        
        UIViewController.gl_top().present(imagePickerVC, animated: true)
    }
    
    private func selectImageFromAlbum() {
        ImageSelector.selectImages(UIViewController.gl_top(), maxCount: remainCount) { picker, images in
            picker.dismiss(animated: true)
            let imageModels = images.compactMap { ImageOrImageUrlAppModel(image: $0, from: .album)}
            self.images.append(contentsOf: imageModels)
        }
    }
    
    
    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let type = info[.mediaType] as? String {
            if type == "public.image" {
                if let image = info[.originalImage] as? UIImage {
                    self.images.append(ImageOrImageUrlAppModel(image: image, from: .backCamera))
                }
            }
        }
    }
}

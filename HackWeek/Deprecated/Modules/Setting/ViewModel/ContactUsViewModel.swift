//
//  ContactUsViewModel.swift
//  AINote
//
//  Created by user on 2024/8/13.
//

import SwiftUI
import Combine
import GLWidget
import GLUtils
import AppModels
import GLModules
import GLMP



class ContactUsViewModel: ObservableObject {
    @Published var emailText = ""
    
    @Published var descText = ""
    
    @Published var images: [ImageOrImageUrlAppModel] = []
    
    @Published var sendButtonState: GLButtonState = .disable
    
    init() {
        Publishers.CombineLatest($emailText, $descText)
            .map { email, desc in
                let trimedEmail: String = (email as NSString).gl_stringByTrim()
                let trimedDesc: String = (desc as NSString).gl_stringByTrim()
                return trimedEmail.isEmpty || trimedDesc.isEmpty ? .disable : .default
            }
            .assign(to: &$sendButtonState)
    }
    
    
    func isValidEmail() -> Bool {
        return (emailText as NSString).gl_validEmail()
    }
    
    
    func onSend(completion: @escaping (Bool) -> Void) {
        if images.count > 0 {
            GLToast.showLoading()
            GLMPUpload.uploadimageOrUrl(images, uploadType: .support) { [weak self] success, results in
                GLToast.dismiss()
                if success {
                    self?.sendReqeust(results, completion: completion)
                } else {
                    completion(false)
                }
            }
            return
        }
        sendReqeust([], completion: completion)
    }
    
    private func sendReqeust(_ imagesUploadResults: [ImageOrImageUrlAppModel], completion: @escaping (Bool) -> Void) {
        let imageUrls = imagesUploadResults.compactMap({ $0.imageUrl })
        let itemIds: [Int] = imagesUploadResults.compactMap({ $0.itemId })
        let fields: [String: Any] = ["itemIds": itemIds]
        let tags: [String] = [GLMPAccount.isVip() ? "VIP" : "Free"]
        
        GLToast.showLoading()
        SupportApis.sendSupportTicket(email: (emailText as NSString).gl_stringByTrim(),
                                      content: (descText as NSString).gl_stringByTrim(),
                                      imageUrls: imageUrls,
                                      type: .normalSupport,
                                      tags: tags,
                                      extraFields: fields) { response in
            GLToast.dismiss()
            completion(response.error == nil)
        }
        
    }
}

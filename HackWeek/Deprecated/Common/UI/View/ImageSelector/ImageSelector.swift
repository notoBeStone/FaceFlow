//
//  ImageSelector.swift
//  AINote
//
//  Created by user on 2024/4/12.
//

import UIKit
import DGPicker
import GLResource

class ImageSelector: NSObject {
    
    typealias CompletionBlock = (_ picker: UIViewController, _ images: [UIImage]) -> Void
    typealias CancelBlock = (_ picker: UIViewController?) -> Void
    
    
    static private let shared = ImageSelector()
    
    private var completionBlock: CompletionBlock?
    private var cancelBlock: CancelBlock?
    
    private override init() {
        super.init()
    }
    
    class func selectImages(_ presentVC: UIViewController, maxCount: UInt = 1, completion: @escaping CompletionBlock, cancel: CancelBlock? = nil) {
        shared.selectImages(presentVC, maxCount: maxCount, completion: completion, cancel: cancel)
    }

}

extension ImageSelector {
    
    private func selectImages(_ presentVC: UIViewController, maxCount: UInt, completion: @escaping CompletionBlock, cancel: CancelBlock?) {
        
        self.completionBlock = completion
        self.cancelBlock = cancel
        
        let configuration = DGPickerConfiguration()
        configuration.mediaTypes = [NSNumber(value: DGPickerMediaType.photo.rawValue), NSNumber(value: DGPickerMediaType.livePhoto.rawValue)]
        configuration.selectionLimit = Int(maxCount)
        configuration.modalPresentationStyle = .fullScreen
        configuration.preferredLanguage = GLLanguage.currentLanguage.code
        configuration.forceUseSystemNavigationStyle = true
        
        let manager = DGPickerManager.sharedInstance()
        
        do {
           try setupManager(manager, configuration: configuration)
        } catch {
            configuration.forceUsePHAssetMode = true
            try? setupManager(manager, configuration: configuration)
        }
        
        manager.delegate = self
        
        let navigationController = UINavigationController(rootViewController: manager.pickerController)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.modalPresentationStyle = .fullScreen
        presentVC.present(navigationController, animated: true)
    }
    
    
    private func setupManager(_ manager: DGPickerManager, configuration: DGPickerConfiguration) throws {
        manager.setup(with: configuration)
    }
}


extension ImageSelector: DGPickerManagerDelegate {
    
    func pickerManager(_ pickerManager: DGPickerManager, pickerController: UIViewController, didFinishPicking result: DGPickerResult?) {

        if let result = result {
            
            result.convert { [weak self] datas in
                var images: [UIImage] = []
                if let datas = datas as? [Data] {
                    images = datas.compactMap({ UIImage(data: $0) })
                }
                self?.completionBlock?(pickerController, images)
            }
            
            DGPickerSelector.sharedInstance().reset()
        } else {
            pickerController.dismiss(animated: true)
            
            if let cancelBlock = cancelBlock {
                cancelBlock(pickerController)
                self.cancelBlock = nil
            }
        }
    }
    
}

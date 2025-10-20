//
//  PhotoBrowser.swift
//  GLCMSResult
//
//  Created by user on 2024/5/13.
//

import UIKit
import GLWidget
import GLComponentAPI
import GLUtils

public class PhotoBrowser: NSObject {
    public static let shared = PhotoBrowser()

    public var browser: GLImageBrowserViewController?
    public var openExternalURLHandler: ((String, String, UIViewController?) -> Void)?
    public var shouldShowUseAsHeadButtonBlock: ((Any, Int) -> Bool)?
    public var didTapUseAsHeadButtonBlock: ((Any, Int) -> Void)?
    public var didDismissWithResultItemsBlock: (([Any]) -> Void)?

    private var images: [BrowserImage] = []
    private var contrastImage: UIImage?
    private weak var vc: UIViewController?

    func directShowImages(_ images: [BrowserImage], withContrastImage contrastImage: UIImage?, index: Int, from viewController: UIViewController?, fromPage: String?) {
        self.images = images
        self.vc = viewController
        self.contrastImage = contrastImage
        
        var imageArray: [Any] = []
        for image in images {
            if let img = image.image {
                imageArray.append(img)
            } else if let imageURL = image.imageURL, !imageURL.isEmpty {
                imageArray.append(imageURL)
            }
        }

        self.browser = GLImageBrowserViewController(target: contrastImage, dataSource: imageArray, currentIndex: index, from: fromPage) { [weak self] index, data in
            guard let self = self else { return nil }
            return self.images[index].cpyRight
        }
        
        self.browser?.delegate = self
        self.browser?.show()
    }

    public func showImages(_ images: [BrowserImage], withContrastImage contrastImage: UIImage?, index: Int, from viewController: UIViewController?, fromPage: String?) {
        self.didDismissWithResultItemsBlock = nil
        self.shouldShowUseAsHeadButtonBlock = nil
        self.didTapUseAsHeadButtonBlock = nil
        
        directShowImages(images, withContrastImage: contrastImage, index: index, from: viewController, fromPage: fromPage)
    }

    public func showImage(_ image: UIImage, from viewController: UIViewController?, fromPage: String?) {
        guard let viewController = viewController else { return }
        let browseImage = BrowserImage()
        browseImage.image = image
        showImages([browseImage], withContrastImage: nil, index: 0, from: viewController, fromPage: fromPage)
    }

    public func showImageURL(_ imageUrl: String, from viewController: UIViewController?, fromPage: String?) {
        guard !imageUrl.isEmpty, let viewController = viewController else { return }
        let browseImage = BrowserImage()
        browseImage.imageURL = imageUrl
        showImages([browseImage], withContrastImage: nil, index: 0, from: viewController, fromPage: fromPage)
    }

    public func showCmsImages(_ cmsImages: [CmsImageModel], withContrastImage contrastImage: UIImage?, index: Int, from viewController: UIViewController?, fromPage: String?) {
        guard let viewController = viewController, let contrastImage = contrastImage, !cmsImages.isEmpty else {
            if let contrastImage = contrastImage {
                showImage(contrastImage, from: viewController, fromPage: fromPage)
            }
            return
        }
        
        var browseImages: [BrowserImage] = []
        for image in cmsImages {
            browseImages.append(BrowserImage(cmsImage: image))
        }
        
        if index >= browseImages.count {
            showImages(browseImages, withContrastImage: contrastImage, index: 0, from: viewController, fromPage: fromPage)
        } else {
            showImages(browseImages, withContrastImage: contrastImage, index: index, from: viewController, fromPage: fromPage)
        }
    }
    
    public static func showImageUrls(_ imageUrls: [String], index: Int, fromPage: String) {
        let view = ImagesViewerView(index: index, images: imageUrls.map({ url in
            let model = ImagesViewerImage(image: nil, imageModel: CmsImageModel.init(type: .cmsTagValueImage, imageUrl: url))
            return model
        }), from: fromPage)
        let vc = GLHostingController(rootView: view)
        vc.modalPresentationStyle = .fullScreen
        UIViewController.gl_top().present(vc, animated: true)
    }
    
    public static func showCmsImages(_ images: [CmsImageModel], index: Int, fromPage: String) {
        let view = ImagesViewerView(index: index, images: images.map({ image in
            let model = ImagesViewerImage(image: nil, imageModel: image)
            return model
        }), from: fromPage)
        let vc = GLHostingController(rootView: view)
        vc.modalPresentationStyle = .fullScreen
        UIViewController.gl_top().present(vc, animated: true)
    }
    
    public static func showImages(images: [UIImage], index: Int, fromPage: String) {
        let view = ImagesViewerView(index: index, images: images.map({ image in
            let model = ImagesViewerImage(image: image, imageModel: nil)
            return model
        }), from: fromPage)
        let vc = GLHostingController(rootView: view)
        vc.modalPresentationStyle = .fullScreen
        UIViewController.gl_top().present(vc, animated: true)
    }
}

extension PhotoBrowser: GLImageBrowserViewControllerDelegate {
    public func imageBrowser(_ controller: GLImageBrowserViewController, didTapLinkWithTitle title: String, url: URL) {
        if let openExternalURLHandler = openExternalURLHandler {
            let urlString = url.absoluteString
            if !urlString.isEmpty {
                controller.close()
                openExternalURLHandler(title, urlString, vc)
            }
        }
    }

    public func imageBrowser(_ controller: GLImageBrowserViewController, shouldShowUseAsHeadButtonForItem item: Any, atIndex index: Int) -> Bool {
        if let shouldShowUseAsHeadButtonBlock = shouldShowUseAsHeadButtonBlock {
            return shouldShowUseAsHeadButtonBlock(item, index)
        }
        return false
    }

    public func imageBrowser(_ controller: GLImageBrowserViewController, didTapUseAsHeadButtonWithItem item: Any, atIndex index: Int) {
        if let didTapUseAsHeadButtonBlock = didTapUseAsHeadButtonBlock {
            didTapUseAsHeadButtonBlock(item, index)
        }
    }

    public func imageBrowser(_ controller: GLImageBrowserViewController, didDismissWithResultItems items: [Any]) {
        if let didDismissWithResultItemsBlock = didDismissWithResultItemsBlock {
            didDismissWithResultItemsBlock(items)
        }
    }

    public func imageBrowser(_ controller: GLImageBrowserViewController, tipsAtIndex index: Int) -> String? {
        if index < images.count {
            return images[index].tip
        }
        return nil
    }
}

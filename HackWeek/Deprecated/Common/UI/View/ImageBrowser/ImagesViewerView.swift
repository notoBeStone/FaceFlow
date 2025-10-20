//
//  ImagesViewerView.swift
//  AINote
//
//  Created by 彭瑞淋 on 2024/10/14.
//

import SwiftUI
import GLComponentAPI
import GLWebImage
import GLWidget
import GLCore
import GLTrackingExtension
import GLUtils

class ImagesViewerImage {
    
    var image: UIImage?
    
    var imageModel: CmsImageModel?
    
    init(image: UIImage? = nil, imageModel: CmsImageModel? = nil) {
        self.image = image
        self.imageModel = imageModel
    }
    
}

struct ImagesViewerView: View {
    
    @State var index: Int
    let images: [ImagesViewerImage]
    let from: String
    
    @State private var showPopover = false
    @State private var buttonFrame: CGRect = .zero
    @State private var popupPosition: CGPoint = .zero
    
    // MARK: Pinch scale
    @State private var scale: CGFloat = 1.0
    @State private var lastScaleValue: CGFloat = 1.0
    
    @State private var dragOffset = CGPoint.zero // 当前拖动的偏移量
    @State private var lastDragOffset = CGPoint.zero
    
    var body: some View {
        ZStack(alignment: .bottomLeading, content: {
            
            ZStack(alignment: .topLeading) {
                TabView(selection: $index) {
                    ForEach(0..<images.count, id: \.self) { idx in
                        ZStack {
                            let image = images[idx]
                            if let imageModel = image.imageModel {
                                GLImage(imageModel.imageUrl)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .background(Color.g5)
                                    .frame(width: GLScreenWidth)
                                    .frame(maxWidth: .infinity)
                                    .tag(idx) // 使用 idx 作为 tag，确保唯一
                                    .clipped()
                            } else if let uiImage = image.image {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .background(
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: GLScreenWidth)
                                            .frame(maxWidth: .infinity)
                                    )
                                    .frame(width: GLScreenWidth)
                                    .frame(maxWidth: .infinity)
                                    .tag(idx) // 使用 idx 作为 tag，确保唯一
                                    .clipped()
                            }
 
                            DraggableView { offset, state in
                                let dealOffset = CGPoint(x: offset.x * scale, y: offset.y * scale)
                                if state == .ended {
                                    dragOffset = CGPointAdd_GLG(dragOffset, lastDragOffset)
                                    lastDragOffset = .zero
                                } else if state == .changed {
                                    let maxOffSet = maxOffset(scale: scale)
                                    
                                    if abs(dealOffset.x + dragOffset.x) < maxOffSet.x {
                                        lastDragOffset.x = dealOffset.x
                                    }
                                    if abs(dealOffset.y + dragOffset.y) < maxOffSet.y {
                                        lastDragOffset.y = dealOffset.y
                                    }
                                }
                            } scaleChange: { value, state in
                                if state == .changed {
                                    let delta = value / self.lastScaleValue
                                    self.lastScaleValue = value
                                    if scale * delta > 1 {
                                        scale *= delta
                                    }
                                } else if state == .ended {
                                    let maxOffSet = maxOffset(scale: scale)
                                    self.lastScaleValue = 1.0
                                    if abs(dragOffset.x) > maxOffSet.x {
                                        dragOffset.x = dragOffset.x > 0 ? maxOffSet.x : -maxOffSet.x
                                    }
                                    if abs(dragOffset.y) > maxOffSet.y {
                                        dragOffset.y = dragOffset.y > 0 ? maxOffSet.y : -maxOffSet.y
                                    }
                                }
                            }
                        }
                        .frame(width: GLScreenWidth)
                        .frame(maxWidth: .infinity)
                        .scaleEffect(idx == index ? scale : 1)
                        .offset(x: idx == index ? dragOffset.x + lastDragOffset.x : 0, y: idx == index ? dragOffset.y + lastDragOffset.y : 0)
                        .onTapGesture {
                            // 需要加个空实现 不然 ios18 以下不会响应下面的 onTap
                        }
                        .onLongPressGesture {
                            GL().Tracking_Event("imageviewer_longpress_click", parameters: [GLT_PARAM_FROM: from])
                            downloadCurrentImage()
                        }
                        .clipped()
                    }
                  
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, StatusBarHeight)
                .padding(.bottom, IPhoneXBottomHeight)
                
                if images.count > 1 {
                    NavBars(index: $index, totalCount: images.count, from: from)
                        .padding(.top, StatusBarHeight)
                }
            }
            .background(Color.black)
            
            if images.count > index, let copyright = images[index].imageModel?.imageCopyright {
                Button {
                    showPopover = true
                    popupPosition = CGPoint(x: buttonFrame.midX, y: buttonFrame.minY - 10) // 上方10个点
                } label: {
                    Image("image_viewer_copyright")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 14)
                    Text(Language.TEXT_COPYRIGHT)
                        .font(.medium(14))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.leading, -2)
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear.onAppear {
                            buttonFrame = geometry.frame(in: .global)
                        }
                    }
                )
                .padding(.bottom, IPhoneXBottomHeight)
                .padding(.leading, 16)
                
                if showPopover {
                    VStack(alignment: .center, content: {
                        HStack(alignment: .top, spacing: 2, content: {
                            AttributedText(self.generateCopyrightString(copyright: copyright), onOpenLink: { url in
                                UIApplication.gl_open(url: url)
                            })
                            .addTextAttribute(
                                font: .regular(16),
                                foregroundColor: .gl_color(0x000000, opacity: 0.9),
                                kern: -0.31,
                                lineHeight: 22
                            )
                            .multilineTextAlignment(.leading)
                            .padding(.leading, 16)
                            
                            Image("tip_close")
                                .renderingMode(.template)
                                .resizable()
                                .foregroundColor(.gl_color(0x000000, opacity: 0.42))
                                .frame(width: 18, height: 18)
                                .padding(.trailing, 12)
                        })
                        .padding(.top, 14)
                        .padding(.bottom, 26)
                    })
                    .background(
                        BubbleShape(arrowCenterX: popupPosition.x - 16)
                            .fill(Color.clear)
                            .background(VisualEffectBlur(effect: UIBlurEffect(style: .systemMaterialLight)))
                            .clipShape(BubbleShape(arrowCenterX: popupPosition.x - 16))
                    )
                    .shadow(radius: 10)
                    .animation(.spring(), value: showPopover)
                    .padding(.bottom, ScreenHeight - popupPosition.y)
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                }
            }
        })
        .onTapGesture {
            if showPopover {
                showPopover = false
            } else {
                GL().Tracking_Event("imageviewer_empty_click", parameters: [GLT_PARAM_FROM: from])
                UIViewController.gl_top().dismiss(animated: true)
            }
        }
        .onChange(of: index) { _ in
            GL().Tracking_Event("imageviewer_scroll", parameters: [GLT_PARAM_FROM: from, GLT_PARAM_INDEX: "\(index)"])
            self.scale = 1
            dragOffset = .zero
            if showPopover {
                showPopover = false
            }
        }
        .ignoresSafeArea(.all)
    }
    
    func downloadCurrentImage() {
        
        UIAlertController.gl_sheetController(with: [
            .init(title: Language.TEXT_DOWNLOAD, style: .default), .init(title: Language.TEXT_CANCEL, style: .cancel)]) { _, idx in
                // download
                if idx == 0 {
                    if let imageUrl = images[self.index].imageModel?.imageUrl {
                        GL().WebImage_DownloadImage(from: imageUrl) {
                            image, _, _ in
                            if let image = image {
                                GL().Tracking_Event("imageviewer_download_click", parameters: [GLT_PARAM_FROM: from])
                                if image.saveToAlbum() {
                                    GLToast.showSuccess(GLMPLanguage.text_save_album_success)
                                } else {
                                    GLToast.showError(GLMPLanguage.text_save_album_fail)
                                }
                            }
                        }
                    } else if let image = images[self.index].image {
                        GL().Tracking_Event("imageviewer_download_click", parameters: [GLT_PARAM_FROM: from])
                        if image.saveToAlbum() {
                            GLToast.showSuccess(GLMPLanguage.text_save_album_success)
                        } else {
                            GLToast.showError(GLMPLanguage.text_save_album_fail)
                        }
                    }
                } else {
                    GL().Tracking_Event("imageviewer_downloadcancel_click", parameters: [GLT_PARAM_FROM: from])
                }
            }
    }
    
    func generateCopyrightString(copyright: CopyrightModel) -> NSAttributedString {
        
        let string: NSMutableAttributedString = NSMutableAttributedString()
        
        if let detailUrl = copyright.detailUrl, detailUrl.count > 0 {
            
            string.append(.init(string: Language.TEXT_PHOTO, attributes: [.link: detailUrl, .underlineStyle: NSNumber(value: 1)]))
        }
        
        if let signature = copyright.author, signature.count > 0 {
            if string.string.count > 0 {
                string.append(.init(string: " "))
            }
            string.append(.init(string: Language.TEXT_BY + " "))
            if let authorlink = copyright.authorlink, authorlink.count > 0 {
                string.append(.init(string: signature, attributes: [.link: authorlink, .underlineStyle: NSNumber(value: 1)]))
            } else {
                string.append(.init(string: signature))
            }
        } else if let authorlink = copyright.authorlink, authorlink.count > 0 {
            if string.string.count > 0 {
                string.append(.init(string: " "))
            }
            string.append(.init(string: Language.TEXT_BY + " "))
            string.append(.init(string: Language.TEXT_AUTHOR, attributes: [.link: authorlink, .underlineStyle: NSNumber(value: 1)]))
        }
        
        if let license = copyright.license, license.count > 0 {
            if string.string.count > 0 {
                string.append(.init(string: " "))
            }
            
            string.append(.init(string: Language.TEXT_USED_UNDER.gl_format(license)))
            
            
            if let certUrl = copyright.certUrl, certUrl.count > 0 {
                let range = (string.string as NSString).range(of: license)
                if range.location != NSNotFound {
                    string.addAttributes([.link: certUrl, .underlineStyle: NSNumber(value: 1)], range: range)
                }
            }
        }
        
        if string.string.count > 0 {
            string.append(.init(string: " / \(Language.TEXT_CROP_FROM_ORIGINAL)"))
        }
        
        return string
    }
    
    func maxOffset(scale: CGFloat) -> CGPoint {
        
        let maxHeight = GLScreenHeight - GLSafeStatusBarHeight - GLSafeBottom
        let maxWidth = GLScreenWidth
        let imageSize = CGSizeMake(maxWidth, maxHeight)
        
        var displaySize =  CGSize(width: imageSize.width * maxHeight / imageSize.height * scale, height: maxHeight * scale)
        
        if imageSize.width / imageSize.height > maxWidth / maxHeight {
            displaySize = CGSize(width: maxWidth * scale, height: imageSize.height * maxWidth / imageSize.width * scale)
        }
                
        let returnValue = CGPoint(x: (displaySize.width - maxWidth) * 0.5, y: (displaySize.height - maxHeight) * 0.5)
        
        return CGPoint(x: max(returnValue.x, 0), y: max(returnValue.y, 0))
        
    }
    
}

private struct NavBars: View {
    
    @Binding var index: Int
    
    let totalCount: Int
    
    let from: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(alignment: .center, spacing: 0) {
                Text("\(index + 1)/\(totalCount)")
                    .font(.medium(18))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
            
            Button {
                UIViewController.gl_top().dismiss(animated: true)
                GL().Tracking_Event("imageviewer_close_click", parameters: [GLT_PARAM_FROM: from])
            } label: {
                Image("icon_close_white_16h")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.leading, 16)
                    .frame(width: 32, height: 32)
            }
        }
        .frame(height: 32)
    }
}

private struct BubbleShape: Shape {
    
    var arrowCenterX: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let cornerRadius: CGFloat = 8
        let arrowHeight: CGFloat = 10
        let arrowWidth: CGFloat = 24
        
        let triangleCurveRadius = 2.0
        
        let arrowCurveRadius = 3.0
        
        let arrowRadiusWidth = arrowWidth * 0.5 - triangleCurveRadius
        
        var path = Path()
        
        let arrowX = max(min(arrowCenterX, rect.width - cornerRadius - arrowWidth * 0.5 - cornerRadius), cornerRadius + arrowWidth / 2.0 + cornerRadius)

        path.move(to: CGPoint(x: cornerRadius, y: 0))
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0))
        path.addArc(center: CGPoint(x: rect.width - cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius - arrowHeight))
        path.addArc(center: CGPoint(x: rect.width - cornerRadius, y: rect.height - cornerRadius - arrowHeight), radius: cornerRadius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: arrowX + arrowWidth / 2.0, y: rect.height - arrowHeight))

        // 两边的弧度
        path.addQuadCurve(to: CGPoint(x: arrowX + triangleCurveRadius, y: rect.height - arrowCurveRadius), control: CGPoint(x: arrowX + triangleCurveRadius + arrowRadiusWidth * 0.7, y: rect.height - arrowHeight))
        // 中间的箭头弧度
        path.addQuadCurve(to: CGPoint(x: arrowX - triangleCurveRadius, y: rect.height - arrowCurveRadius), control: .init(x: arrowX, y: rect.height))
        // 两边的弧度
        path.addQuadCurve(to: CGPoint(x: arrowX - arrowWidth * 0.5, y: rect.height - arrowHeight), control: CGPoint(x: arrowX - triangleCurveRadius - arrowRadiusWidth * 0.7, y: rect.height - arrowHeight))
        
        path.addLine(to: CGPoint(x: cornerRadius, y: rect.height - arrowHeight))
        path.addArc(center: CGPoint(x: cornerRadius, y: rect.height - cornerRadius - arrowHeight), radius: cornerRadius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        
        return path
    }
}


private struct VisualEffectBlur: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: effect)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}


struct DraggableView: UIViewRepresentable {
     
    var offsetChange: (CGPoint, UIGestureRecognizer.State)->()
    
    var scaleChange: (CGFloat, UIGestureRecognizer.State)->()

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        panGesture.minimumNumberOfTouches = 2
        panGesture.delegate = context.coordinator
        view.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        pinchGesture.delegate = context.coordinator
        view.addGestureRecognizer(pinchGesture)
        
        

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }

    // Coordinator 用于处理手势
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: DraggableView

        init(_ parent: DraggableView) {
            self.parent = parent
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let draggedView = gesture.view else { return }
            let translation = gesture.translation(in: draggedView.superview)
            
            parent.offsetChange(translation, gesture.state)
        }
        
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            parent.scaleChange(gesture.scale, gesture.state)
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            if gestureRecognizer is UIPinchGestureRecognizer, otherGestureRecognizer is UIPanGestureRecognizer, otherGestureRecognizer.numberOfTouches == 2 {
                return true
            }
            if otherGestureRecognizer is UIPinchGestureRecognizer, gestureRecognizer is UIPanGestureRecognizer, gestureRecognizer.numberOfTouches == 2  {
                return true
            }
            return false
        }
    }
}

//#Preview(body: {
//    ImagesViewerView(index: 0, images: [.init(type: .cmsTagValueImage, imageUrl: "https://stagestatic.AINoteai.com/qa2/item/original_url/507456699628126208/1721648809-98222497931.webp"), .init(type: .cmsTagValueImage, imageUrl: "https://stagestatic.AINoteai.com/qa2/item/original_url/507456699628126208/1721648809-98222497931.webp")], from: "")
//})

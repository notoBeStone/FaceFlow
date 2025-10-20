//
//  SeekGoodReviewPopView.swift
//  IOSProject
//
//  Created by Martin on 2024/3/6.
//

import UIKit
import GLUtils
import GLAnalyticsUI
import GLTrackingExtension

class SeekGoodReviewPopView: BasePopCenterView {
    let source: GoodReviewType
    let handler: (_ writeReview: Bool)->()
    
    init(source: GoodReviewType, handler: @escaping (_: Bool) -> Void) {
        self.source = source
        self.handler = handler
        super.init(frame: ScreenBounds)
        self.shouldShowCloseButton = false
        configUI()
        self.gl_track(type: .exposure, name: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        let rootView = SeekGoodReviewPopContentView {[weak self] type in
            self?.writeReview(type)
        }
        
        let hostingVC = GLHostingController(rootView: rootView, isNavigationBarHidden: true, ignoresSafeArea: false)
        hostingVC.view.backgroundColor = .clear
        
        self.contentView.addSwiftUI(viewController: hostingVC) { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func writeReview(_ type: SeekGoodReviewPopActionType) {
        switch type {
        case .writeReview:
            self.tracking("goodreviewcustom_writereview_click")
        case .notNow:
            self.tracking("goodreviewcustom_notnow_click")
        case .close:
            self.tracking("goodreviewcustom_close_click")
        }
        self.dismissAnimated(true) {}
        self.handler(type == .writeReview)
    }
}

extension SeekGoodReviewPopView: GLAPageProtocol {
    var pageName: String? {
        "goodreviewcustom"
    }
    
    var pageParams: [String : Any]? {
        [GLT_PARAM_TYPE: source.event]
    }
}

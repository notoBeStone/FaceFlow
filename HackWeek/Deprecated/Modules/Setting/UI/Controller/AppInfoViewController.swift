//
//  AppInfoViewController.swift
//  AINote
//
//  Created by user on 2024/8/12.
//

import SwiftUI
import Combine
import GLResource
import GLUtils
import GLAnalyticsUI
import GLMP

#if DEBUG
struct AppInfoView_Preview: PreviewProvider {
    static var previews: some View {
        GLPreviewController {
            AppInfoViewController()
        }
    }
}
#endif

class AppInfoViewController: BaseViewController, GLAPageProtocol {
    var pageName: String? = "appinfo"
    var pageParams: [String : Any]?
    let actionModel = AppInfoActionModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func setUI() {
        super.setUI()
        
    }
    
    override func setSwiftUIView() {
        super.setSwiftUIView()
        
        let swiftUIView = AppInfoView(actionModel: actionModel)
        view.addSwiftUI(viewController: GLHostingController(rootView: swiftUIView)) { make in
            if self.isHiddenNavigationBar {
                make.edges.equalToSuperview()
            } else {
                make.top.equalTo(self.navigationView.snp.bottom)
                make.bottom.leading.trailing.equalToSuperview()
            }
        }
    }
    
    override func setActions() {
        super.setActions()
        
        actionModel.backAction.sink { [weak self] in
            guard let self = self else { return }
            self.onBackAction()
        }.store(in: &cancellables)
        
        actionModel.thirdPartyAction.sink { [weak self] urlString in
            guard let self = self else { return }
            self.onThirdPartyAction(urlString)
        }.store(in: &cancellables)
        
        actionModel.moreAboutUsAction.sink { [weak self] in
            guard let self = self else { return }
            self.onAboutUsAction()
        }.store(in: &cancellables)
    }
    
    private func onBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func onThirdPartyAction(_ urlString: String) {
        GLMPRouter.open(DeepLinks.commonBottomSheetDialogWebViewDeepLink(from: self.pageName ?? "", pageName: nil, title: nil, url: urlString))
    }
    
    private func onAboutUsAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

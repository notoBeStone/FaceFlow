//
//  ContactUsViewController.swift
//  AINote
//
//  Created by user on 2024/8/13.
//

import SwiftUI
import Combine
import GLResource
import GLUtils
import GLWidget
import GLAnalyticsUI
import GLMP

#if DEBUG
struct ContactUsView_Preview: PreviewProvider {
    static var previews: some View {
        GLPreviewController {
            ContactUsViewController(from: "preview")
        }
    }
}
#endif

class ContactUsViewController: BaseViewController, GLAPageProtocol, GLMPRouterDeepLinkDelegate {
    var deeplink: DeepLink?
    
    var pageName: String? = "contactus"
    var pageParams: [String : Any]?
    
    let viewModel = ContactUsViewModel()
    let actionModel = ContactUsActionModel()
    
    
    required convenience init?(deeplink: DeepLink) {
        self.init(from: deeplink.from)
        self.deeplink = deeplink
    }
    
    required init(from: String) {
        super.init(from: from)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func setUI() {
        super.setUI()
        
    }
    
    override func setSwiftUIView() {
        super.setSwiftUIView()
        
        let swiftUIView = ContactUsView(viewModel: viewModel, actionModel: actionModel)
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
        
        actionModel.sendAction.sink { [weak self] in
            guard let self = self else { return }
            self.onSendAction()
        }.store(in: &cancellables)
    }
    
    
    private func onBackAction() {
        self.popOrDismissController(defaultType: .pop, animated: true)
    }
    
    
    private func onSendAction() {
        guard viewModel.isValidEmail() else {
            GLToast.showError(GLMPLanguage.text_invalid_email)
            return
        }
        
        viewModel.onSend { [weak self] success in
            if success {
                GLToast.showSuccess(GLMPLanguage.msg_update_advice_me_sucess)
                self?.popOrDismissController(defaultType: .pop, animated: true)
            } else {
                GLToast.showError(GLMPLanguage.error_connect_fail_try_again)
            }
        }
    }
}

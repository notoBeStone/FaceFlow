//
//  ComposableUIComponent.swift
//  ComposableComponent
//
//  Created by stephenwzl on 2025/7/22.
//

import Foundation
import SwiftUI
import GLWidget
import GLUtils
import GLAnalyticsUI
import GLMP

public protocol ComposableUIComponent: View {
    associatedtype ComponentProps = Void
    init(props: ComponentProps)
    var props: ComponentProps { get }
}

public protocol ComposablePageComponent: ComposableUIComponent {
    var pageName: String { get }
    var pageTrackingParams: [String: Any]? { get }
}

extension ComposableUIComponent where ComponentProps == Void {
    init() {
        self.init(props: ())
    }
}


// MARK: - Type-erased HostingController
class AnyComposableHostingController: GLBaseHostingViewController<AnyView>, GLAPageProtocol {
    private let component: any ComposablePageComponent
    
    var pageName: String? {
        component.pageName.isEmpty ? nil : component.pageName
    }
    
    var pageParams: [String : Any]? {
        component.pageTrackingParams
    }
    
    init(rootView: any ComposablePageComponent) {
        self.component = rootView
        super.init(rootView: AnyView(
            rootView
                .environment(\.tracking, { (eventName, params) in
                    var pageParams = rootView.pageTrackingParams ?? [:]
                    let eventParams = pageParams.gl_merge(params ?? [:])
                    GLMPTracking.tracking(eventName, parameters: eventParams)
                })
        ))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

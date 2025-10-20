//
//  ScrollView+Ext.swift
//  AINote
//
//  Created by user on 2024/10/30.
//

import Foundation
import SwiftUI
import SwiftUIIntrospect


extension ScrollView {
 
    func dismissKeyboardOnDrag() -> some View {
        return self.modifier(ScrollViewKeyboardDismissModifier())
    }
}


struct ScrollViewKeyboardDismissModifier: ViewModifier {

    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .scrollDismissesKeyboard(.immediately)
        } else {
            content
                .introspect(.scrollView, on: .iOS(.v15)) { scrollView in
                    scrollView.keyboardDismissMode = .onDrag
                }
        }
    }
}

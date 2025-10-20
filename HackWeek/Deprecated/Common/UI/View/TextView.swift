//
//  TextView.swift
//  KnitAI
//
//  Created by stephenwzl on 2025/3/18.
//

import SwiftUI

extension Text {
    func fontColor(_ color: Color) -> Self {
        self.foregroundColor(color)
    }
    
    func block(_ alignment: Alignment = .leading, textAlignment: TextAlignment = .leading) -> some View {
        self.multilineTextAlignment(textAlignment)
            .frame(maxWidth: .infinity, alignment: alignment)
    }
}

extension View {
    func block(_ alignment: Alignment = .leading) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
}

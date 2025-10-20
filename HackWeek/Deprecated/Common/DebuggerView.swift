//
//  DebuggerView.swift
//  SupplementID
//
//  Created by stephenwzl on 2025/6/12.
//

import SwiftUI

struct DebuggerView: View {
    let message: String
    var body: some View {
        VStack {
            Text(message)
                .fontMedium(16)
                .colorGWL
                .blockLeading
            Spacer(minLength: 0)
            Button {
                Navigator.dismiss(false)
            } label: {
                Image(.commonClose24)
                    .renderingMode(.template)
                    .resizableSquare(32)
                    .foregroundStyle(Color.gwL)
            }
        }
        .pt(Consts.safeTop)
        .pb(Consts.safeBottom)
        .phmd
        .background(Color.red)
    }
}

#Preview {
    DebuggerView(message: "hello message")
}

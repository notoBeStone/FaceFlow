//
//  DynamicTextView.swift
//  D2CDemo
//
//  Created by Martin on 2024/2/23.
//

import SwiftUI
import Combine
import GLUtils

struct DynamicTextViewConfig {
    let minHeight: Double
    let maxHeight: Double
    let lineSpacing: Double?
    let maxCount: Int?
    let accentColor: Color?
}

struct DynamicTextView: View {
    let color: Color
    let font: Font
    let config: DynamicTextViewConfig
    let submitLabel: SubmitLabel
    let fixedHeight: Bool = false
    @Binding var text: String
    @State var lastText: String
    @Binding var isFirstResponse: Bool
    @FocusState private var isFocused: Bool
    @State private var textEditorHeight : CGFloat?
    let submitHandler: ()->()
    
    init(color: Color,
         font: Font,
         config: DynamicTextViewConfig,
         submitLabel: SubmitLabel = .send,
         fixedHeight: Bool = false,
         text: Binding<String>,
         isFirstResponse: Binding<Bool>, submitHandler: @escaping () -> Void) {
        self.color = color
        self.font = font
        self.config = config
        self.submitLabel = submitLabel
        self._text = text
        self._isFirstResponse = isFirstResponse
        self.submitHandler = submitHandler
        self._lastText = .init(initialValue: text.wrappedValue)
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            TextEditor(text: $text)
                .textFieldStyle(.plain)
                .focused($isFocused)
                .accentColor(self.config.accentColor)
                .font(font)
                .lineSpacing(lineSpacing)
                .foregroundColor(color)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: height)
                .submitLabel(submitLabel)
                .textEditorBackground(Color.clear)
                .textEditorInnerInset()
                .onReceive(Just(text), perform: { newText in
                    if let maxCount = self.config.maxCount {
                        self.limitText(maxCount)
                    }
                    
                    if lastText.newLineCount < self.text.newLineCount {
                        text = lastText
                        self.isFocused = false
                        self.isFirstResponse = false
                        self.submitHandler()
                    } else {
                        lastText = self.text
                    }
                })
        }
        .if(!fixedHeight) {
            $0.background(
                Text(text)
                    .font(font)
                    .foregroundColor(.clear)
                    .disabled(true)
                    .lineSpacing(lineSpacing)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .readSize {
                        self.textEditorHeight = $0.height
                    }
                    .fixedSize(horizontal: false, vertical: true)
            )
        }
        .onAppear {
            self.isFocused = isFirstResponse
        }
        .onChange(of: self.isFirstResponse) { newValue in
            if self.isFocused != newValue {
                self.isFocused = newValue
            }
        }
        .onChange(of: isFocused) { newValue in
            if isFirstResponse != newValue {
                isFirstResponse = newValue
            }
        }
    }
    
    private var lineSpacing: Double {
        return self.config.lineSpacing ?? 0
    }
    
    private func limitText(_ upper: Int) {
        let scenarios = text
        if scenarios.count > upper {
            text = String(text.prefix(upper))
        }
    }
    
    private var height: Double {
        var height: Double
        if let textEditorHeight = self.textEditorHeight {
            height = textEditorHeight - (Consts.textEditorInset.top + Consts.textEditorInset.bottom)
        } else {
            height = self.config.minHeight
        }
        height = max(height, self.config.minHeight)
        height = min(height, self.config.maxHeight)
        return height
    }
}

private extension String {
    var newLineCount: Int {
        self.filter { $0 == "\n" }.count
    }
}

//
//  KeybaordAvoidCoveredHelper.swift
//  IOSProject
//
//  Created by Martin on 2024/9/20.
//

import UIKit
import SnapKit
import GLUtils
import Combine

struct KeybaordAvoidCoveredTextEditor {
    let view: UIView
    let bottomInset: Double
    let fullRaised: Bool
    
    init(view: UIView, bottomInset: Double = 10.0, fullRaised: Bool = false) {
        self.view = view
        self.bottomInset = bottomInset
        self.fullRaised = fullRaised
    }
}

protocol KeybaordAvoidCoveredProtocol: AnyObject {
    var ownerView: UIView { get }
    var keyboardContentView: UIView { get }
    var introspectTextEditorAction: PassthroughSubject<KeybaordAvoidCoveredTextEditor, Never>? { get }
}

class KeybaordAvoidCoveredHelper {
    private var cancellables: Set<AnyCancellable> = []
    typealias OWNER = KeybaordAvoidCoveredProtocol
    var enable = true
    var keyboardContentBottomConstraint: SnapKit.Constraint?
    private(set) var textEditors: [KeybaordAvoidCoveredTextEditor] = []
    private var keyboardShow: Bool = false
    weak var owner: OWNER?
    
    init(owner: OWNER?) {
        self.owner = owner
    }
    
    func config() {
        addKeybaordObserver()
        self.owner?.introspectTextEditorAction?.receive(on: RunLoop.main).sink(receiveValue: {[weak self] textEditor in
            self?.appendTextEditor(textEditor.view, inset: textEditor.bottomInset, fullRaised: textEditor.fullRaised)
        }).store(in: &cancellables)
    }
    
    func appendTextEditor(_ view: UIView, inset: Double = 10.0, fullRaised: Bool = false) {
        var textEditors = self.textEditors
        textEditors.removeAll {$0.view === view}
        textEditors.insert(.init(view: view, bottomInset: inset, fullRaised: fullRaised), at: 0)
        self.textEditors = textEditors
    }
    
    // MARK: - Keyboard
    private func addKeybaordObserver() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector:  #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private var textEditor: KeybaordAvoidCoveredTextEditor? {
        return self.textEditors.first(where: {$0.view.isFirstResponder})
    }
    
    private func bottomEdgeOf(view: UIView) -> CGFloat {
        guard let owner = self.owner else { return 0 }
        let contentView = owner.keyboardContentView
        let frame = view.gl_convertRect(to: contentView)
        let maxY = frame.maxY
        let bottomEdge = contentView.bounds.size.height - maxY
        return bottomEdge
    }
    
    private func keyboardShow(height: CGFloat, duration: Double) {
        guard let owner = self.owner, self.enable else { return }
        
        let contentView = owner.keyboardContentView
        let view = owner.ownerView
        var bottom = height
        var fullRaiseUp: Bool = false
        if let textEditor {
            let bottomEdge = bottomEdgeOf(view: textEditor.view)
            bottom = bottom - bottomEdge + textEditor.bottomInset
            fullRaiseUp = textEditor.fullRaised
        }
        
        if fullRaiseUp || bottom > height {
            bottom = height
        }
        
        self.keyboardContentBottomConstraint?.deactivate()
        contentView.snp.makeConstraints { make in
            self.keyboardContentBottomConstraint = make.bottom.equalToSuperview().inset(bottom).constraint
        }
        
        view.setNeedsLayout()
        UIView.animate(withDuration: max(duration, 0.3)) {
            view.layoutIfNeeded()
        }
    }
    
    private func keyboardHide(duration: Double) {
        guard let owner = self.owner, self.enable else { return }
        
        let contentView = owner.keyboardContentView
        let view = owner.ownerView
        self.keyboardContentBottomConstraint?.deactivate()
        contentView.snp.makeConstraints { make in
            self.keyboardContentBottomConstraint = make.bottom.equalToSuperview().constraint
        }
        view.setNeedsLayout()
        UIView.animate(withDuration: duration) {
            view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let height = notification.keyboardHeight, let duration = notification.keyboardDuration else {
            return
        }
        keyboardShow = true
        keyboardShow(height: height, duration: duration)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.keyboardDuration else {
            return
        }
        keyboardShow = false
        keyboardHide(duration: duration)
    }
}

extension Notification {
    var keyboardHeight: CGFloat? {
        guard let keyboardFrame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return nil
        }
        return keyboardFrame.cgRectValue.size.height
    }
    
    var keyboardDuration: Double? {
        guard let duration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {
            return nil
        }
        return duration.doubleValue
    }
}

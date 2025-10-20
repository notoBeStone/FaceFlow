//
//  CombineActionProtocol.swift
//  AINote
//
//  Created by Martin on 2024/11/7.
//

import Foundation
import Combine

protocol CombineActionProtocol: AnyObject {
    var cancellables: Set<AnyCancellable> { get set }
}

extension CombineActionProtocol {
    func sink<Element>(action: PassthroughSubject<Element, Never>, handler: @escaping (Element) -> Void) {
        action.receive(on: RunLoop.main).sink { data in
            handler(data)
        }.store(in: &cancellables)
    }
    
    func sink(action: ObservableObjectPublisher, handler: @escaping () -> Void) {
        action.receive(on: RunLoop.main).sink { data in
            handler()
        }.store(in: &cancellables)
    }
}

//
//  VideosPlayView+Ext.swift
//  Mejor
//
//  Created by Martin on 2023/7/11.
//

import Foundation

extension VideosPlayView {
    func loadData(_ data: VideosPlayView.Data, completion: @escaping (_ url: URL?)->()) {
        switch data {
//        case .remote(let urlString):
        case .local(let path):
            self.loadLocal(path: path, completion: completion)
        }
    }
    
    private func loadLocal(path: String, completion: @escaping (_ url: URL?)->()) {
        let url = URL(fileURLWithPath: path)
        completion(url)
    }
}

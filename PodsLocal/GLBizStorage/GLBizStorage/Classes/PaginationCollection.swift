//
//  PaginationCollection.swift
//  GLBizStorage
//
//  Created by stephenwzl on 2024/12/16.
//

import Foundation
import DGMessageAPI
import GLMP
import Combine

public class PaginationCollection<T: GLBizStorageSchema>: ObservableObject {
    @Published public private(set) var items: [T] = []
    @Published public private(set) var isLoading: Bool = false
    public var hasMore: Bool {
        if let count = totalCount {
            return items.count < count
        }
        return true
    }
    private let pageSize: Int
    private let query: Query<T>
    private var lastId: Int64?
    private var totalCount: Int?
    private var cancellables: Set<AnyCancellable> = []

    public init(query: Query<T>) {
        self.pageSize = query.pageSize
        self.query = query
    }
    
    public func subscribeChanges() {
        T.schemaUpdatedPublisher.receive(on: RunLoop.main).sink { info in
            guard let item = info.item as? T else {
                return
            }
            switch info.type {
            case .add:
                self.items.append(item)
                let sortedItems = self.items.sorted { $0.createAt > $1.createAt }
                self.items = sortedItems
            case .update:
                if let index = self.items.firstIndex(where: { $0.bizStorageId == info.id }) {
                    self.items[index] = item
                    let sortedItems = self.items.sorted { $0.createAt > $1.createAt }
                    self.items = sortedItems
                }
            case .delete:
                if let index = self.items.firstIndex(where: { $0.bizStorageId == info.id }) {
                    self.items.remove(at: index)
                    let sortedItems = self.items.sorted { $0.createAt > $1.createAt }
                    self.items = sortedItems
                }
            case .unknown:
                break
            }
        }.store(in: &cancellables)
    }

    public func loadMore() async throws {
        if isLoading {
            return
        }
        if !hasMore {
            return
        }
        await MainActor.run {
            isLoading = true
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        var request = query.toBizStorageRequest()
        request.lastId = self.lastId
        request.pageSize = self.pageSize
        let res = await GLMPNetwork.request(request)
        if let error = res.error {
            throw error
        }
        guard let response = res.data else {
            throw GLBizStorageError.itemLoadFailed
        }
        totalCount = response.total
        if let lastObject = response.list.last {
                    self.lastId = lastObject.storageId
        } else {
            self.lastId = nil
        }
        
        let objects = try response.list.map { item in
            guard let object = T.from(item) as? T else {
                throw GLBizStorageError.serializationError
            }
            return object
        }
        await MainActor.run {
            // 使用 Dictionary 存储 items
            var itemMap = Dictionary(uniqueKeysWithValues: self.items.map { ($0.bizStorageId, $0) })
            
            // 更新 itemMap
            for newItem in objects {
                itemMap[newItem.bizStorageId] = newItem
            }
            
            // 根据 updateAt 排序并更新 items
            self.items = itemMap.values.sorted { $0.createAt > $1.createAt }
        }
    }

}

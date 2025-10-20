/**
 * @file LazyCollection.swift
 * @brief 懒加载集合
 * @author wang.zhilong
 * @date 2024-12-06
 */

import Foundation
import DGMessageAPI
import GLMP

public enum GLBizStorageError: Error {
    case indexOutOfRange
    case itemLoadFailed
    case serializationError
    case requestError
}


public class LazyObjectCollection<T: GLBizStorageSchema>: ObservableObject {
    private let pageSize: Int
    /// displayed count
    @Published public private(set) var count: Int = 0
    @Published public private(set) var isLoading: Bool = false
    private let query: Query<T>
    private var filterPredicate: ((T) -> Bool)?
    private var filteredObjects: [T] = []
    private let actor: LazyCollectionActor<T>
    
    /// 初始化
    /// - Parameters:
    ///   - query: 查询条件
    ///   - pageSize: 分页大小
    public init(query: Query<T>) {
        self.query = query
        self.pageSize = query.pageSize
        self.actor = LazyCollectionActor(query: query, pageSize: query.pageSize)
        Task {
            try? await self.actor.loadNextPage()
            await applyFilter()
        }
    }
    
    public subscript(index: Int) -> T {
        get async throws {
            // 靠近或者超出索引范围，需要加载下一页
            let needLoad = index >= filteredObjects.count - 1
            if needLoad {
                try await self.actor.loadNextPage()
                await applyFilter()
            }
            if index < filteredObjects.count {
                return filteredObjects[index]
            }
            throw GLBizStorageError.indexOutOfRange
        }
    }


    /// Set a filter predicate
    public func setFilter(predicate: @escaping (T) -> Bool) {
        self.filterPredicate = predicate
        Task {
            await applyFilter()
        }
    }

    /// Clear the filter
    public func clearFilter() {
        if self.filterPredicate != nil {
            self.filterPredicate = nil
            Task {
                await applyFilter()
            }
        }
    }

    /// Apply the current filter to the cached objects
    private func applyFilter() async {
        let filteredObjects = await actor.getFilteredObjects(filter: filterPredicate)
        self.filteredObjects = filteredObjects
        await MainActor.run {
            self.count = filteredObjects.count
            self.objectWillChange.send()
        }
    }
}

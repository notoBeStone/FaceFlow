import Foundation
import DGMessageAPI
import GLMP


actor LazyCollectionActor<T: GLBizStorageSchema> {
    private var cachedObjects: [T] = []
    private var lastId: Int64?
    private let pageSize: Int
    private let query: Query<T>
    private var isRequestInProgress: Bool = false
    var totalCount: Int = 0
    var hasRequested = false
    
    init(query: Query<T>, pageSize: Int) {
        self.query = query
        self.pageSize = pageSize
    }

    func isDataLoaded(index: Int) -> Bool {
        return cachedObjects.count > index
    }

    func getObject(index: Int) async throws -> T? {
        if cachedObjects.count > index {
            return cachedObjects[index]
        }
        try await loadNextPage()
        if cachedObjects.count > index {
            return cachedObjects[index]
        }
        return nil
    }
    
    func loadNextPage() async throws -> Void {
        // 防止重复请求
        guard !isRequestInProgress else {
            return
        }
        guard hasMoreData() else {
            return
        }
        isRequestInProgress = true
        defer {
            isRequestInProgress = false
            hasRequested = true
        }
        
        // 构建请求
        var request = query.toBizStorageRequest()
        request.lastId = lastId
        request.pageSize = pageSize
        let res = await GLMPNetwork.request(request)
        if let error = res.error {
            debugPrint(error.localizedDescription)
            throw GLBizStorageError.itemLoadFailed
        }
        guard let response = res.data else {
            throw GLBizStorageError.itemLoadFailed
        }
        
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
        self.totalCount = response.total
        // self.totalPage = Int(ceil(Double(response.totalCount) / Double(pageSize)))
        self.cachedObjects.append(contentsOf: objects)
    }
    
    func getCachedObjects() -> [T] {
        return cachedObjects
    }
    
    func hasMoreData() -> Bool {
        if !hasRequested {
            return true
        }
        return cachedObjects.count < totalCount
    }

    func getFilteredObjects(filter: ((T) -> Bool)?) -> [T] {
        if let filter = filter {
            return cachedObjects.filter(filter)
        }
        return cachedObjects
    }
}

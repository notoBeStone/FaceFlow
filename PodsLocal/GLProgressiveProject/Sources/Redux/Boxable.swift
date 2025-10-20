import Foundation

/// 类型擦除包装器，用于比较 Equatable 值
public struct AnyEquatable {
    let value: any Equatable
    private let equalityCheck: (Any) -> Bool
    
    init<T: Equatable>(_ value: T) {
        self.value = value
        self.equalityCheck = { otherValue in
            guard let otherValue = otherValue as? T else { return false }
            return value == otherValue
        }
    }
    
    func isEqual(to other: AnyEquatable) -> Bool {
        return equalityCheck(other.value)
    }
}

@resultBuilder
public struct EqTupleBuilder {
    public static func buildBlock(_ components: any Equatable...) -> [AnyEquatable] {
        return components.map { AnyEquatable($0) }
    }
}

public struct EqTuple: Equatable {
    private let values: [AnyEquatable]

    public init(@EqTupleBuilder values: () -> [AnyEquatable]) {
        self.values = values()
    }

    public init(_ values: any Equatable...) {
        self.values = values.map { AnyEquatable($0) }
    }

    public static func == (lhs: EqTuple, rhs: EqTuple) -> Bool {
        guard lhs.values.count == rhs.values.count else {
            return false
        }
        
        for (index, lhsItem) in lhs.values.enumerated() {
            let rhsItem = rhs.values[index]
            if !lhsItem.isEqual(to: rhsItem) {
                return false
            }
        }
        return true
    }

    public subscript<T>(index: Int) -> T {
        return values[index].value as! T
    }
}

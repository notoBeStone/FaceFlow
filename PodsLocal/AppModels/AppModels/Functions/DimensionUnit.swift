import Foundation

/**
 * DimensionUnit 是一个表示长度单位的枚举类，
 * 包括米、厘米、毫米、千米、英寸、英尺、码、英里和光年等，常用于日常生活和科学研究中。
 */
public enum DimensionUnit: Int {
    /**
     * 米
     * 米 (m)，国际单位制中的基本长度单位。
     * 缩写为 m。
     */
    case M = 0

    /**
     * 厘米
     * 厘米 (cm)，国际单位制中的长度单位。
     * 缩写为 cm。
     */
    case CM = 1

//    /**
//     * 毫米
//     * 毫米 (mm)，国际单位制中的长度单位。
//     * 缩写为 mm。
//     */
//    case MM = 2

//    /**
//     * 千米
//     * 千米 (km)，国际单位制中的长度单位。
//     * 缩写为 km。
//     */
//    case KM = 3

    /**
     * 英寸
     * 英寸 (in)，英国和美国习惯用的长度单位。
     * 缩写为 in。
     */
    case IN = 4

    /**
     * 英尺
     * 英尺 (ft)，英国和美国习惯用的长度单位。
     * 缩写为 ft。
     */
    case FT = 5

//    /**
//     * 码
//     * 码 (yd)，英国和美国习惯用的长度单位。
//     * 缩写为 yd。
//     */
//    case YD = 6

//    /**
//     * 英里
//     * 英里 (mi)，英国和美国习惯用的长度单位。
//     * 缩写为 mi。
//     */
//    case MI = 7

//    /**
//     * 光年
//     * 光年 (ly)，天文学中使用的长度单位。
//     * 缩写为 ly。
//     */
//    case LY = 8

//    /**
//     * 海里
//     * 海里 (nm)，航海中使用的长度单位。
//     * 缩写为 nm。
//     */
//    case NM = 9

    /**
     * 根据整数值返回对应的 DimensionUnit 枚举值。
     *
     * - Parameter value: 整数值。
     * - Throws: 如果没有对应的枚举值，抛出错误。
     * - Returns: DimensionUnit 枚举值。
     */
    public static func fromValue(_ value: Int) throws -> DimensionUnit {
        if let unit = DimensionUnit(rawValue: value) {
            return unit
        } else {
            throw NSError(domain: "Invalid value \(value) for DimensionUnit", code: value, userInfo: nil)
        }
    }
}

/**
 * 获取长度单位的字符串表示。
 * - Returns: 长度单位的字符串。
 */
public extension DimensionUnit {
    var unit: String {
        switch self {
        case .M:
            return "m"
        case .CM:
            return "cm"
        case .FT:
            return "ft"
        case .IN:
            return "in"
//        case .MM:
//            return "mm"
//        case .KM:
//            return "km"
//        case .YD:
//            return "yd"
//        case .MI:
//            return "mi"
//        case .LY:
//            return "ly"
//        case .NM:
//            return "nm"
        }
    }
    
    var name: String {
        switch self {
        case .M:
            return "M"
        case .CM:
            return "CM"
        case .IN:
            return "IN"
        case .FT:
            return "FT"
        }
    }
}

/**
 * DimensionMetric 是一个表示具有单位的长度值的数据结构。
 */
public struct DimensionMetric: Equatable {
    /**
     * 长度数值，必须大于等于 0。
     */
    public let number: Float

    /**
     * 长度单位。
     */
    public let unit: DimensionUnit

    public init(number: Float, unit: DimensionUnit) {
        self.number = number
        self.unit = unit
    }

    /**
     * 返回对象的字符串表示。
     */
    public func toString() -> String {
        return "DimensionMetric(number: \(number), unit: \(unit))"
    }

    /**
     * 获取用于 JSON 表示的字典。
     */
    public func getJsonMap() -> [String: Any] {
        return ["number": number, "unit": unit.rawValue]
    }

    /**
     * 将对象转换为 JSON 字符串。
     */
    func toJson() -> String {
        let jsonMap = getJsonMap()
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonMap, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return "{}"
    }

    /**
     * 从 JSON 对象创建 DimensionMetric 对象。
     *
     * - Parameter jsonObject: JSON 对象。
     * - Throws: 如果缺少必要字段，抛出错误。
     * - Returns: DimensionMetric 对象。
     */
    static func fromJson(_ jsonObject: [String: Any]) throws -> DimensionMetric {
        guard let numberValue = jsonObject["number"] else {
            throw NSError(domain: "number is required", code: 0, userInfo: nil)
        }

        let number: Float
        if let num = numberValue as? Float {
            number = num
        } else if let num = numberValue as? Double {
            number = Float(num)
        } else if let num = numberValue as? Int {
            number = Float(num)
        } else {
            throw NSError(domain: "Invalid number value", code: 0, userInfo: nil)
        }

        guard let unitValue = jsonObject["unit"] as? Int,
              let unit = DimensionUnit(rawValue: unitValue) else {
            throw NSError(domain: "unit is required", code: 0, userInfo: nil)
        }
        return DimensionMetric(number: number, unit: unit)
    }

    /**
     * 从 JSON 字符串创建 DimensionMetric 对象。
     *
     * - Parameter jsonString: JSON 字符串。
     * - Throws: 如果解析失败，抛出错误。
     * - Returns: DimensionMetric 对象。
     */
    static func fromJson(_ jsonString: String) throws -> DimensionMetric {
        if let data = jsonString.data(using: .utf8),
           let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            return try fromJson(jsonObject)
        }
        throw NSError(domain: "Invalid JSON string", code: 0, userInfo: nil)
    }
    
    public static func == (lhs: DimensionMetric, rhs: DimensionMetric) -> Bool {
        return lhs.number == rhs.number && lhs.unit == rhs.unit
    }
}

/**
 * 扩展 DimensionMetric，添加实例方法。
 */
public extension DimensionMetric {
    /**
     * 检查长度是否为零。
     * - Returns: 如果长度为零，返回 true。
     */
    func isZero() -> Bool {
        return self.number == 0
    }

    /**
     * 格式化输出长度。
     * - Returns: 格式化后的字符串。
     */
    func format() -> String {
        return "\(self.number) \(self.unit.unit)"
    }

    /**
     * 获取格式化后的长度字符串。
     *
     * - Parameter shouldConvertBaseUnit: 是否转换为基本单位。
     * - Returns: 格式化后的字符串。
     */
    func getFormattedString(shouldConvertBaseUnit: Bool) -> String {
        let intNumber = Int(self.number)
        switch self.unit {
        case .M:
            return "\(intNumber) m"
        case .CM:
            if !shouldConvertBaseUnit {
                return "\(intNumber) cm"
            } else {
                let highEnd = intNumber / 100
                let lowEnd = intNumber % 100
                if highEnd == 0 {
                    return "\(lowEnd) cm"
                } else if lowEnd == 0 {
                    return "\(highEnd) m"
                } else {
                    return "\(highEnd) m \(lowEnd) cm"
                }
            }
        case .IN:
            if !shouldConvertBaseUnit {
                return "\(intNumber) in"
            } else {
                let highEnd = intNumber / 12
                let lowEnd = intNumber % 12
                if highEnd == 0 {
                    return "\(lowEnd) in"
                } else if lowEnd == 0 {
                    return "\(highEnd) ft"
                } else {
                    return "\(highEnd) ft \(lowEnd) in"
                }
            }
        case .FT:
            return "\(intNumber) ft"
        }
    }

    /**
     * 将长度转换为米。
     * - Returns: 转换后的 DimensionMetric 对象。
     */
    func toM() -> DimensionMetric {
        switch self.unit {
        case .M:
            return self
        case .CM:
            return DimensionMetric(number: self.number / 100, unit: .M)
//        case .MM:
//            return DimensionMetric(number: self.number / 1000, unit: .M)
//        case .KM:
//            return DimensionMetric(number: self.number * 1000, unit: .M)
        case .IN:
            return DimensionMetric(number: self.number * 0.0254, unit: .M)
        case .FT:
            return DimensionMetric(number: self.number * 0.3048, unit: .M)
//        case .YD:
//            return DimensionMetric(number: self.number * 0.9144, unit: .M)
//        case .MI:
//            return DimensionMetric(number: self.number * 1609.34, unit: .M)
//        case .LY:
//            return DimensionMetric(number: self.number * 9.461e15, unit: .M)
//        case .NM:
//            return DimensionMetric(number: self.number * 1852, unit: .M)
        }
    }

    /**
     * 将长度转换为厘米。
     * - Returns: 转换后的 DimensionMetric 对象。
     */
    func toCM() -> DimensionMetric {
        switch self.unit {
        case .M:
            return DimensionMetric(number: self.number * 100, unit: .CM)
        case .CM:
            return self
//        case .MM:
//            return DimensionMetric(number: self.number / 10, unit: .CM)
//        case .KM:
//            return DimensionMetric(number: self.number * 100000, unit: .CM)
        case .IN:
            return DimensionMetric(number: self.number * 2.54, unit: .CM)
        case .FT:
            return DimensionMetric(number: self.number * 30.48, unit: .CM)
//        case .YD:
//            return DimensionMetric(number: self.number * 91.44, unit: .CM)
//        case .MI:
//            return DimensionMetric(number: self.number * 160934, unit: .CM)
//        case .LY:
//            return DimensionMetric(number: self.number * 9.461e17, unit: .CM)
//        case .NM:
//            return DimensionMetric(number: self.number * 185200, unit: .CM)
        }
    }

//    /**
//     * 将长度转换为毫米。
//     * - Returns: 转换后的 DimensionMetric 对象。
//     */
//    func toMM() -> DimensionMetric {
//        switch self.unit {
//        case .M:
//            return DimensionMetric(number: self.number * 1000, unit: .MM)
//        case .CM:
//            return DimensionMetric(number: self.number * 10, unit: .MM)
//        case .MM:
//            return self
//        case .KM:
//            return DimensionMetric(number: self.number * 1e6, unit: .MM)
//        case .IN:
//            return DimensionMetric(number: self.number * 25.4, unit: .MM)
//        case .FT:
//            return DimensionMetric(number: self.number * 304.8, unit: .MM)
//        case .YD:
//            return DimensionMetric(number: self.number * 914.4, unit: .MM)
//        case .MI:
//            return DimensionMetric(number: self.number * 1.60934e6, unit: .MM)
//        case .LY:
//            return DimensionMetric(number: self.number * 9.461e18, unit: .MM)
//        case .NM:
//            return DimensionMetric(number: self.number * 1852000, unit: .MM)
//        }
//    }

//    /**
//     * 将长度转换为千米。
//     * - Returns: 转换后的 DimensionMetric 对象。
//     */
//    func toKM() -> DimensionMetric {
//        switch self.unit {
//        case .M:
//            return DimensionMetric(number: self.number / 1000, unit: .KM)
//        case .CM:
//            return DimensionMetric(number: self.number / 100000, unit: .KM)
//        case .MM:
//            return DimensionMetric(number: self.number / 1e6, unit: .KM)
//        case .KM:
//            return self
//        case .IN:
//            return DimensionMetric(number: self.number * 2.54e-5, unit: .KM)
//        case .FT:
//            return DimensionMetric(number: self.number * 3.048e-4, unit: .KM)
//        case .YD:
//            return DimensionMetric(number: self.number * 9.144e-4, unit: .KM)
//        case .MI:
//            return DimensionMetric(number: self.number * 1.60934, unit: .KM)
//        case .LY:
//            return DimensionMetric(number: self.number * 9.461e12, unit: .KM)
//        case .NM:
//            return DimensionMetric(number: self.number * 1.852, unit: .KM)
//        }
//    }

    /**
     * 将长度转换为英寸。
     * - Returns: 转换后的 DimensionMetric 对象。
     */
    func toIN() -> DimensionMetric {
        switch self.unit {
        case .M:
            return DimensionMetric(number: self.number / 0.0254, unit: .IN)
        case .CM:
            return DimensionMetric(number: self.number / 2.54, unit: .IN)
//        case .MM:
//            return DimensionMetric(number: self.number / 25.4, unit: .IN)
//        case .KM:
//            return DimensionMetric(number: self.number / 2.54e-5, unit: .IN)
        case .IN:
            return self
        case .FT:
            return DimensionMetric(number: self.number * 12, unit: .IN)
//        case .YD:
//            return DimensionMetric(number: self.number * 36, unit: .IN)
//        case .MI:
//            return DimensionMetric(number: self.number * 63360, unit: .IN)
//        case .LY:
//            return DimensionMetric(number: self.number * 3.724e17, unit: .IN)
//        case .NM:
//            return DimensionMetric(number: self.number * 72913.4, unit: .IN)
        }
    }

    /**
     * 将长度转换为英尺。
     * - Returns: 转换后的 DimensionMetric 对象。
     */
    func toFT() -> DimensionMetric {
        switch self.unit {
        case .M:
            return DimensionMetric(number: self.number / 0.3048, unit: .FT)
        case .CM:
            return DimensionMetric(number: self.number / 30.48, unit: .FT)
//        case .MM:
//            return DimensionMetric(number: self.number / 304.8, unit: .FT)
//        case .KM:
//            return DimensionMetric(number: self.number / 3.048e-4, unit: .FT)
        case .IN:
            return DimensionMetric(number: self.number / 12, unit: .FT)
        case .FT:
            return self
//        case .YD:
//            return DimensionMetric(number: self.number * 3, unit: .FT)
//        case .MI:
//            return DimensionMetric(number: self.number * 5280, unit: .FT)
//        case .LY:
//            return DimensionMetric(number: self.number * 3.937e16, unit: .FT)
//        case .NM:
//            return DimensionMetric(number: self.number * 6076.12, unit: .FT)
        }
    }

//    /**
//     * 将长度转换为码。
//     * - Returns: 转换后的 DimensionMetric 对象。
//     */
//    func toYD() -> DimensionMetric {
//        switch self.unit {
//        case .M:
//            return DimensionMetric(number: self.number / 0.9144, unit: .YD)
//        case .CM:
//            return DimensionMetric(number: self.number / 91.44, unit: .YD)
//        case .MM:
//            return DimensionMetric(number: self.number / 914.4, unit: .YD)
//        case .KM:
//            return DimensionMetric(number: self.number / 9.144e-4, unit: .YD)
//        case .IN:
//            return DimensionMetric(number: self.number / 36, unit: .YD)
//        case .FT:
//            return DimensionMetric(number: self.number / 3, unit: .YD)
//        case .YD:
//            return self
//        case .MI:
//            return DimensionMetric(number: self.number * 1760, unit: .YD)
//        case .LY:
//            return DimensionMetric(number: self.number * 1.181e16, unit: .YD)
//        case .NM:
//            return DimensionMetric(number: self.number * 2025.37, unit: .YD)
//        }
//    }

//    /**
//     * 将长度转换为英里。
//     * - Returns: 转换后的 DimensionMetric 对象。
//     */
//    func toMI() -> DimensionMetric {
//        switch self.unit {
//        case .M:
//            return DimensionMetric(number: self.number / 1609.34, unit: .MI)
//        case .CM:
//            return DimensionMetric(number: self.number / 160934, unit: .MI)
//        case .MM:
//            return DimensionMetric(number: self.number / 1.609e6, unit: .MI)
//        case .KM:
//            return DimensionMetric(number: self.number / 1.60934, unit: .MI)
//        case .IN:
//            return DimensionMetric(number: self.number / 63360, unit: .MI)
//        case .FT:
//            return DimensionMetric(number: self.number / 5280, unit: .MI)
//        case .YD:
//            return DimensionMetric(number: self.number / 1760, unit: .MI)
//        case .MI:
//            return self
//        case .LY:
//            return DimensionMetric(number: self.number * 5.879e12, unit: .MI)
//        case .NM:
//            return DimensionMetric(number: self.number * 1.15078, unit: .MI)
//        }
//    }

//    /**
//     * 将长度转换为光年。
//     * - Returns: 转换后的 DimensionMetric 对象。
//     */
//    func toLY() -> DimensionMetric {
//        switch self.unit {
//        case .M:
//            return DimensionMetric(number: self.number / 9.461e15, unit: .LY)
//        case .CM:
//            return DimensionMetric(number: self.number / 9.461e17, unit: .LY)
//        case .MM:
//            return DimensionMetric(number: self.number / 9.461e18, unit: .LY)
//        case .KM:
//            return DimensionMetric(number: self.number / 9.461e12, unit: .LY)
//        case .IN:
//            return DimensionMetric(number: self.number / 3.724e17, unit: .LY)
//        case .FT:
//            return DimensionMetric(number: self.number / 3.937e16, unit: .LY)
//        case .YD:
//            return DimensionMetric(number: self.number / 1.181e16, unit: .LY)
//        case .MI:
//            return DimensionMetric(number: self.number / 5.879e12, unit: .LY)
//        case .LY:
//            return self
//        case .NM:
//            return DimensionMetric(number: self.number / 1.852e12, unit: .LY)
//        }
//    }

//    /**
//     * 将长度转换为海里。
//     * - Returns: 转换后的 DimensionMetric 对象。
//     */
//    func toNM() -> DimensionMetric {
//        switch self.unit {
//        case .M:
//            return DimensionMetric(number: self.number / 1852, unit: .NM)
//        case .CM:
//            return DimensionMetric(number: self.number / 185200, unit: .NM)
//        case .MM:
//            return DimensionMetric(number: self.number / 1.852e6, unit: .NM)
//        case .KM:
//            return DimensionMetric(number: self.number / 1.852, unit: .NM)
//        case .IN:
//            return DimensionMetric(number: self.number / 72913.4, unit: .NM)
//        case .FT:
//            return DimensionMetric(number: self.number / 6076.12, unit: .NM)
//        case .YD:
//            return DimensionMetric(number: self.number / 2025.37, unit: .NM)
//        case .MI:
//            return DimensionMetric(number: self.number * 0.868976, unit: .NM)
//        case .LY:
//            return DimensionMetric(number: self.number * 5.108e12, unit: .NM)
//        case .NM:
//            return self
//        }
//    }
}

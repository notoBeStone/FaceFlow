import Foundation

/**
 * VolumeUnit 是一个枚举类，表示不同的体积单位，
 * 包括升、毫升、加仑、夸脱、品脱、杯、汤匙、茶匙、盎司、立方米、
 * 立方厘米、立方毫米、立方英寸、立方英尺和立方码，
 * 这些单位在日常生活和科学研究中常用。
 */
public enum VolumeUnit: Int {
    /**
     * 升
     * 升 (L)，国际单位制中的体积单位。
     * 一个升等于 1,000 毫升。
     */
    case L = 0

    /**
     * 毫升
     * 毫升 (mL)，国际单位制中的体积单位。
     * 一个毫升等于 0.001 升。
     */
    case ML = 1

    /**
     * 立方米
     * 立方米 (m³)，国际单位制中的体积单位。
     * 一个立方米等于 1,000 升，或 1,000,000 毫升。
     */
    case M3 = 2

    /**
     * 立方厘米
     * 立方厘米 (cm³)，国际单位制中的体积单位。
     * 一个立方厘米等于 0.001 升，或 1 毫升。
     */
    case CM3 = 3

    /**
     * 立方毫米
     * 立方毫米 (mm³)，国际单位制中的体积单位。
     * 一个立方毫米等于 0.000001 升。
     */
    case MM3 = 4

//    /**
//     * 加仑
//     * 加仑 (gal)，英国和美国习惯用的体积单位。
//     * 一个加仑等于 4.54609 升，或 4546.09 毫升。
//     */
//    case GALLON = 5

//    /**
//     * 夸脱
//     * 夸脱 (qt)，英国和美国习惯用的体积单位。
//     * 一个夸脱等于 1.13652 升，或 1136.52 毫升。
//     */
//    case QT = 6

    /**
     * 品脱
     * 品脱 (pt)，英国和美国习惯用的体积单位。
     * 一个品脱等于 0.568261 升，或 568.261 毫升。
     */
    case PT = 7

//    /**
//     * 杯
//     * 杯 (c)，英国和美国习惯用的体积单位。
//     * 一个杯等于 0.236588 升，或 236.588 毫升。
//     */
//    case CUP = 8

//    /**
//     * 汤匙
//     * 汤匙 (Tbsp)，英国和美国习惯用的体积单位。
//     * 一个汤匙等于 0.0147868 升，或 14.7868 毫升。
//     */
//    case TABLESPOON = 9

//    /**
//     * 茶匙
//     * 茶匙 (Tsp)，英国和美国习惯用的体积单位。
//     * 一个茶匙等于 0.00492892 升，或 4.92892 毫升。
//     */
//    case TEASPOON = 10

    /**
     * 盎司
     * 盎司，英国和美国习惯用的体积单位。
     * 一个盎司等于 0.0295735 升，或 29.5735 毫升。
     */
    case OZ = 11

    /**
     * 立方英寸
     * 立方英寸 (in³)，英国和美国习惯用的体积单位。
     * 一个立方英寸等于 0.0163871 升，或 16.3871 毫升。
     */
    case IN3 = 12

    /**
     * 立方英尺
     * 立方英尺 (ft³)，英国和美国习惯用的体积单位。
     * 一个立方英尺等于 28.3168 升，或 28,316.8 毫升。
     */
    case FT3 = 13

    /**
     * 立方码
     * 立方码 (yd³)，英国和美国习惯用的体积单位。
     * 一个立方码等于 764.555 升，或 764,555 毫升。
     */
    case YD3 = 14

    /**
     * 根据整数值返回对应的 VolumeUnit 枚举值。
     *
     * - Parameter value: 整数值。
     * - Throws: 如果没有对应的枚举值，抛出错误。
     * - Returns: VolumeUnit 枚举值。
     */
    public static func fromValue(_ value: Int) throws -> VolumeUnit {
        if let unit = VolumeUnit(rawValue: value) {
            return unit
        } else {
            throw NSError(domain: "Invalid value \(value) for VolumeUnit", code: value, userInfo: nil)
        }
    }
}

/**
 * 获取体积单位的字符串表示。
 *
 * - Returns: 体积单位的字符串。
 */
public extension VolumeUnit {
    var unit: String {
        switch self {
        case .L:
            return "L"
        case .ML:
            return "mL"
        case .M3:
            return "m³"
        case .CM3:
            return "cm³"
        case .MM3:
            return "mm³"
        case .PT:
            return "pt"
        case .OZ:
            return "oz"
        case .IN3:
            return "in³"
        case .FT3:
            return "ft³"
        case .YD3:
            return "yd³"
//        case .GALLON:
//            return "gal"
//        case .QT:
//            return "qt"
//        case .CUP:
//            return "cup"
//        case .TABLESPOON:
//            return "Tbsp"
//        case .TEASPOON:
//            return "Tsp"
        }
    }
}

/**
 * VolumeMetric 是一个表示体积的结构体，
 * 包括体积的数值和单位。
 */
public struct VolumeMetric {
    /**
     * 体积数值，必须大于等于 0。
     */
    public let number: Float

    /**
     * 体积单位。
     */
    public let unit: VolumeUnit

    public init(number: Float, unit: VolumeUnit) {
        self.number = number
        self.unit = unit
    }

    /**
     * 返回对象的字符串表示。
     */
    func toString() -> String {
        return "VolumeMetric(number: \(number), unit: \(unit))"
    }

    /**
     * 获取用于 JSON 表示的字典。
     */
    func getJsonMap() -> [String: Any] {
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
     * 从 JSON 字符串创建 VolumeMetric 对象。
     *
     * - Parameter json: JSON 字符串。
     * - Throws: 如果解析失败，抛出错误。
     * - Returns: VolumeMetric 对象。
     */
    static func fromJson(_ json: String) throws -> VolumeMetric {
        if let data = json.data(using: .utf8),
           let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            return try fromJson(jsonObject)
        }
        throw NSError(domain: "Invalid JSON string", code: 0, userInfo: nil)
    }

    /**
     * 从 JSON 对象创建 VolumeMetric 对象。
     *
     * - Parameter jsonObject: JSON 对象。
     * - Throws: 如果缺少必要字段，抛出错误。
     * - Returns: VolumeMetric 对象。
     */
    static func fromJson(_ jsonObject: [String: Any]) throws -> VolumeMetric {
        guard let numberValue = jsonObject["number"] else {
            throw NSError(domain: "Incorrect JSON for VolumeMetric: number is required", code: 0, userInfo: nil)
        }

        let number: Float
        if let num = numberValue as? Float {
            number = num
        } else if let num = numberValue as? Double {
            number = Float(num)
        } else if let num = numberValue as? Int {
            number = Float(num)
        } else {
            throw NSError(domain: "Invalid number value in VolumeMetric", code: 0, userInfo: nil)
        }

        guard let unitValue = jsonObject["unit"] as? Int,
              let unit = VolumeUnit(rawValue: unitValue) else {
            throw NSError(domain: "Incorrect JSON for VolumeMetric: unit is required", code: 0, userInfo: nil)
        }

        return VolumeMetric(number: number, unit: unit)
    }
}

/**
 * 扩展 VolumeMetric，添加实例方法。
 */
public extension VolumeMetric {
    /**
     * 检查体积是否为零。
     * - Returns: 如果体积为零，返回 true。
     */
    func isZero() -> Bool {
        return self.number == 0
    }

    /**
     * 将体积转换为升。
     */
    func toLiter() -> VolumeMetric {
        switch self.unit {
        case .L:
            return self
        case .ML:
            return VolumeMetric(number: self.number * 0.001, unit: .L)
        case .M3:
            return VolumeMetric(number: self.number * 1000, unit: .L)
        case .CM3:
            return VolumeMetric(number: self.number * 0.001, unit: .L)
        case .MM3:
            return VolumeMetric(number: self.number * 0.000001, unit: .L)
        case .PT:
            return VolumeMetric(number: self.number * 0.568261, unit: .L)
        case .OZ:
            return VolumeMetric(number: self.number * 0.0295735, unit: .L)
        case .IN3:
            return VolumeMetric(number: self.number * 0.0163871, unit: .L)
        case .FT3:
            return VolumeMetric(number: self.number * 28.3168, unit: .L)
        case .YD3:
            return VolumeMetric(number: self.number * 764.555, unit: .L)
        }
    }

    /**
     * 将体积转换为毫升。
     */
    func toMilliliter() -> VolumeMetric {
        switch self.unit {
        case .L:
            return VolumeMetric(number: self.number * 1000, unit: .ML)
        case .ML:
            return self
        case .M3:
            return VolumeMetric(number: self.number * 1_000_000, unit: .ML)
        case .CM3:
            return VolumeMetric(number: self.number, unit: .ML)
        case .MM3:
            return VolumeMetric(number: self.number * 0.001, unit: .ML)
        case .PT:
            return VolumeMetric(number: self.number * 568.261, unit: .ML)
        case .OZ:
            return VolumeMetric(number: self.number * 29.5735, unit: .ML)
        case .IN3:
            return VolumeMetric(number: self.number * 16.3871, unit: .ML)
        case .FT3:
            return VolumeMetric(number: self.number * 28_316.8, unit: .ML)
        case .YD3:
            return VolumeMetric(number: self.number * 764_555, unit: .ML)
        }
    }

    /**
     * 将体积转换为立方米。
     */
    func toCubicMeter() -> VolumeMetric {
        switch self.unit {
        case .L:
            return VolumeMetric(number: self.number * 0.001, unit: .M3)
        case .ML:
            return VolumeMetric(number: self.number * 0.000001, unit: .M3)
        case .M3:
            return self
        case .CM3:
            return VolumeMetric(number: self.number * 0.000001, unit: .M3)
        case .MM3:
            return VolumeMetric(number: self.number * 1e-9, unit: .M3)
        case .PT:
            return VolumeMetric(number: self.number * 0.000568261, unit: .M3)
        case .OZ:
            return VolumeMetric(number: self.number * 0.0000295735, unit: .M3)
        case .IN3:
            return VolumeMetric(number: self.number * 0.0000163871, unit: .M3)
        case .FT3:
            return VolumeMetric(number: self.number * 0.0283168, unit: .M3)
        case .YD3:
            return VolumeMetric(number: self.number * 0.764555, unit: .M3)
        }
    }

    /**
     * 将体积转换为立方厘米。
     */
    func toCubicCentimeter() -> VolumeMetric {
        switch self.unit {
        case .L:
            return VolumeMetric(number: self.number * 1000, unit: .CM3)
        case .ML:
            return VolumeMetric(number: self.number, unit: .CM3)
        case .M3:
            return VolumeMetric(number: self.number * 1_000_000, unit: .CM3)
        case .CM3:
            return self
        case .MM3:
            return VolumeMetric(number: self.number * 0.001, unit: .CM3)
        case .PT:
            return VolumeMetric(number: self.number * 568.261, unit: .CM3)
        case .OZ:
            return VolumeMetric(number: self.number * 29.5735, unit: .CM3)
        case .IN3:
            return VolumeMetric(number: self.number * 16.3871, unit: .CM3)
        case .FT3:
            return VolumeMetric(number: self.number * 28_316.8, unit: .CM3)
        case .YD3:
            return VolumeMetric(number: self.number * 764_555, unit: .CM3)
        }
    }

    /**
     * 将体积转换为立方毫米。
     */
    func toCubicMillimeter() -> VolumeMetric {
        switch self.unit {
        case .L:
            return VolumeMetric(number: self.number * 1_000_000, unit: .MM3)
        case .ML:
            return VolumeMetric(number: self.number * 1000, unit: .MM3)
        case .M3:
            return VolumeMetric(number: self.number * 1e9, unit: .MM3)
        case .CM3:
            return VolumeMetric(number: self.number * 1000, unit: .MM3)
        case .MM3:
            return self
        case .PT:
            return VolumeMetric(number: self.number * 568_261, unit: .MM3)
        case .OZ:
            return VolumeMetric(number: self.number * 29_573.5, unit: .MM3)
        case .IN3:
            return VolumeMetric(number: self.number * 16_387.1, unit: .MM3)
        case .FT3:
            return VolumeMetric(number: self.number * 28_316_800, unit: .MM3)
        case .YD3:
            return VolumeMetric(number: self.number * 764_555_000, unit: .MM3)
        }
    }

    /**
     * 将体积转换为品脱。
     */
    func toPint() -> VolumeMetric {
        switch self.unit {
        case .L:
            return VolumeMetric(number: self.number * 1.75975, unit: .PT)
        case .ML:
            return VolumeMetric(number: self.number * 0.00175975, unit: .PT)
        case .M3:
            return VolumeMetric(number: self.number * 1759.75, unit: .PT)
        case .CM3:
            return VolumeMetric(number: self.number * 0.00175975, unit: .PT)
        case .MM3:
            return VolumeMetric(number: self.number * 1.75975e-6, unit: .PT)
        case .PT:
            return self
        case .OZ:
            return VolumeMetric(number: self.number * 0.0625, unit: .PT)
        case .IN3:
            return VolumeMetric(number: self.number * 0.0346321, unit: .PT)
        case .FT3:
            return VolumeMetric(number: self.number * 59.8442, unit: .PT)
        case .YD3:
            return VolumeMetric(number: self.number * 1615.79, unit: .PT)
        }
    }

    /**
     * 将体积转换为盎司。
     */
    func toOunce() -> VolumeMetric {
        switch self.unit {
        case .L:
            return VolumeMetric(number: self.number * 33.814, unit: .OZ)
        case .ML:
            return VolumeMetric(number: self.number * 0.033814, unit: .OZ)
        case .M3:
            return VolumeMetric(number: self.number * 33_814, unit: .OZ)
        case .CM3:
            return VolumeMetric(number: self.number * 0.033814, unit: .OZ)
        case .MM3:
            return VolumeMetric(number: self.number * 3.3814e-5, unit: .OZ)
        case .PT:
            return VolumeMetric(number: self.number * 20, unit: .OZ)
        case .OZ:
            return self
        case .IN3:
            return VolumeMetric(number: self.number * 0.554113, unit: .OZ)
        case .FT3:
            return VolumeMetric(number: self.number * 957.506, unit: .OZ)
        case .YD3:
            return VolumeMetric(number: self.number * 25_852.7, unit: .OZ)
        }
    }

    /**
     * 将体积转换为立方英寸。
     */
    func toCubicInch() -> VolumeMetric {
        switch self.unit {
        case .L:
            return VolumeMetric(number: self.number * 61.0237, unit: .IN3)
        case .ML:
            return VolumeMetric(number: self.number * 0.0610237, unit: .IN3)
        case .M3:
            return VolumeMetric(number: self.number * 61_023.7, unit: .IN3)
        case .CM3:
            return VolumeMetric(number: self.number * 0.0610237, unit: .IN3)
        case .MM3:
            return VolumeMetric(number: self.number * 6.10237e-5, unit: .IN3)
        case .PT:
            return VolumeMetric(number: self.number * 34.6779, unit: .IN3)
        case .OZ:
            return VolumeMetric(number: self.number * 1.80469, unit: .IN3)
        case .IN3:
            return self
        case .FT3:
            return VolumeMetric(number: self.number * 1728, unit: .IN3)
        case .YD3:
            return VolumeMetric(number: self.number * 46_656, unit: .IN3)
        }
    }

    /**
     * 将体积转换为立方英尺。
     */
    func toCubicFoot() -> VolumeMetric {
        switch self.unit {
        case .L:
            return VolumeMetric(number: self.number * 0.0353147, unit: .FT3)
        case .ML:
            return VolumeMetric(number: self.number * 3.53147e-5, unit: .FT3)
        case .M3:
            return VolumeMetric(number: self.number * 35.3147, unit: .FT3)
        case .CM3:
            return VolumeMetric(number: self.number * 3.53147e-5, unit: .FT3)
        case .MM3:
            return VolumeMetric(number: self.number * 3.53147e-8, unit: .FT3)
        case .PT:
            return VolumeMetric(number: self.number * 0.0167101, unit: .FT3)
        case .OZ:
            return VolumeMetric(number: self.number * 0.00104438, unit: .FT3)
        case .IN3:
            return VolumeMetric(number: self.number * 0.000578704, unit: .FT3)
        case .FT3:
            return self
        case .YD3:
            return VolumeMetric(number: self.number * 27, unit: .FT3)
        }
    }

    /**
     * 将体积转换为立方码。
     */
    func toCubicYard() -> VolumeMetric {
        switch self.unit {
        case .L:
            return VolumeMetric(number: self.number * 0.00130795, unit: .YD3)
        case .ML:
            return VolumeMetric(number: self.number * 1.30795e-6, unit: .YD3)
        case .M3:
            return VolumeMetric(number: self.number * 1.30795, unit: .YD3)
        case .CM3:
            return VolumeMetric(number: self.number * 1.30795e-6, unit: .YD3)
        case .MM3:
            return VolumeMetric(number: self.number * 1.30795e-9, unit: .YD3)
        case .PT:
            return VolumeMetric(number: self.number * 0.000618891, unit: .YD3)
        case .OZ:
            return VolumeMetric(number: self.number * 3.86807e-5, unit: .YD3)
        case .IN3:
            return VolumeMetric(number: self.number * 2.14335e-5, unit: .YD3)
        case .FT3:
            return VolumeMetric(number: self.number * 0.037037, unit: .YD3)
        case .YD3:
            return self
        }
    }
}

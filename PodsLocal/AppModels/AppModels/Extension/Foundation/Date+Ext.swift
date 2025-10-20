//
//  Date+Ext.swift
//  AppModels
//
//  Created by user on 2024/6/11.
//

import Foundation

extension Date {
    
    public var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    // "2024-09-03" 这种格式
    public func formatyyyyMMdd() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
    
    public func formatMMM() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM."
        return dateFormatter.string(from: self)
    }
    
    //"April" 完整月份名称
    public func formatMMMM() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self)
    }
    
    // "April 16" 这种格式
    public func formatMMMMdd() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd"
        return dateFormatter.string(from: self)
    }
    
    // "July 04, 2024" 这种格式
    public func formatMMMMddyyyy() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter.string(from: self)
    }
    
    // "27 July, 2024" 这种格式
    public func formatddMMMMyyyy() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM,yyyy"
        return dateFormatter.string(from: self)
    }
    
    /// 判断当前日期是否是今天
    public var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    public func isSameDay(_ date: Date) -> Bool {
        return Calendar.current.isDate(date, inSameDayAs: self)
    }
    
    /// 判断当前日期是否在另一个日期之前（仅比较自然日，不考虑时间部分）
    public func isBeforeInDays(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDay1 = calendar.startOfDay(for: self)
        let startOfDay2 = calendar.startOfDay(for: date)
        return startOfDay1 < startOfDay2
    }
    
    /// 判断当前日期是否在另一个日期之后（仅比较自然日，不考虑时间部分）
    public func isAfterInDays(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDay1 = calendar.startOfDay(for: self)
        let startOfDay2 = calendar.startOfDay(for: date)
        return startOfDay1 > startOfDay2
    }
    
    
    public func daysSinceDate(_ date: Date?) -> Int? {
        guard let date = date else {
            return nil
        }
        
        let calendar = Calendar.current
        let components1: DateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let components2: DateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        if let date1 = calendar.date(from: components1), let date2 = calendar.date(from: components2) {
            let components = calendar.dateComponents([.day], from: date1, to: date2)
            return components.day
        }
        return nil
    }
    
    // daysSinceDate的别名方法，用于Android翻译代码
    public func daysBetween(_ date: Date) -> Int? {
        return daysSinceDate(date)
    }
    
    func getStartOfDay() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let dayString = formatter.string(from: self)
        return formatter.date(from: dayString)
    }
}

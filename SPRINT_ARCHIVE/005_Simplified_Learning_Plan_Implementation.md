# Sprint 005: 简化版学习计划功能实现

## 完成时间
2025年10月14日

## 迭代概述
完成了简化版学习计划功能的核心实现，基于艾宾浩斯遗忘曲线设计了自动化的复习系统，为用户提供了科学的单词学习节奏。

## 完成的功能

### ✅ 简化版遗忘曲线算法实现
- **复习间隔计算**：实现了 [0, 1, 2, 4, 7, 15] 天的间隔序列
- **自动提升机制**：答对时自动提升掌握程度和复习间隔
- **重置机制**：答错时降低掌握程度，重置复习间隔为1天
- **智能计算**：根据当前间隔和掌握程度动态计算下次复习时间

### ✅ 扩展WordModel数据模型
在现有WordModel中添加了学习计划相关字段：
- `nextReviewDate: Date` - 下次复习日期
- `reviewInterval: Int` - 当前复习间隔（天数）
- `lastReviewDate: Date?` - 上次复习日期
- `reviewCount: Int` - 复习次数
- `needsReview: Bool` - 是否需要复习（计算属性）

### ✅ 学习计划管理器（WordBookManager扩展）
新增了完整的学习计划管理功能：
- `getTodayReviewWords(limit:)`: 获取今日需要复习的单词列表
- `markWordReviewed(_:correct:)`: 标记单词复习状态并自动计算下次复习时间
- `markWordsReviewed(_:)`: 批量标记多个单词的复习状态
- `updateAllLearningPlans()`: 自动更新所有单词的学习计划
- `calculateOptimalReviewInterval(for:)`: 根据单词状态计算最优复习间隔

### ✅ 复习统计功能
实现了完整的复习统计系统：
- `ReviewStatistics` 结构体：包含今日复习数、正确率、待复习数等统计信息
- `getReviewStatistics()`: 获取复习统计数据
- `getUpcomingReviewPlan(days:)`: 获取未来几天的复习计划
- 简化的统计逻辑：基于掌握程度判断复习正确率

### ✅ SwiftData查询优化
扩展了WordModel的查询谓词：
- `predicate(needsReview:)`: 获取需要复习的单词
- `predicate(reviewDateInRange:_)`: 根据复习日期范围获取单词
- `predicate(masteryLevelGreaterOrEqual:)`: 根据掌握程度获取单词
- 新增排序描述符：按复习时间、复习次数、复习间隔排序

## 技术实现亮点

### 1. 简化版遗忘曲线算法
```swift
static let reviewIntervals = [0, 1, 2, 4, 7, 15] // 简化的6级间隔
```
- 0表示当天可以再次复习
- 逐步延长复习间隔，符合记忆规律
- 答错时重置为1天间隔，确保及时复习

### 2. 自动化学习计划管理
```swift
func markAsReviewed(correct: Bool) {
    // 自动更新掌握程度
    // 自动计算下次复习时间
    // 自动更新复习统计
}
```
- 一键标记复习状态，无需手动管理
- 智能计算下次复习时间
- 自动更新学习进度

### 3. 完善的统计系统
- 今日复习统计：复习数量、正确率
- 未来复习计划：未来7天的复习安排
- 学习进度统计：总单词数、已掌握数量、待复习数量

### 4. 优化的数据查询
- 支持多种查询条件：按复习状态、日期范围、掌握程度
- 灵活的排序选项：按复习时间、掌握程度、创建时间等
- 高效的数据获取：使用SwiftData的查询优化

## 核心算法流程

### 复习流程
1. **获取今日复习单词** → `getTodayReviewWords()`
2. **用户标记复习结果** → `markWordReviewed(correct: Bool)`
3. **自动计算下次复习时间** → 内置算法处理
4. **更新统计数据** → 自动更新复习统计

### 复习间隔计算
```swift
static func getNextReviewInterval(after currentInterval: Int) -> Int {
    guard let currentIndex = reviewIntervals.firstIndex(of: currentInterval) else {
        return reviewIntervals[1] // 默认返回1天
    }
    let nextIndex = min(currentIndex + 1, reviewIntervals.count - 1)
    return reviewIntervals[nextIndex]
}
```

## 文件结构更新
```
HackWeek/Features/WordBook/
├── Models/
│   └── WordModel.swift (扩展了学习计划字段)
├── Managers/
│   └── WordBookManager.swift (扩展了学习计划管理功能)
├── Data/
│   └── WordBookDataContainer.swift (保持不变)
└── Views/
    └── WordBookExampleView.swift (保持不变)
```

## 接口总览

### 新增的WordModel方法
- `markAsReviewed(correct: Bool)`: 标记复习状态
- `reviewStatusDescription: String`: 获取复习状态描述
- `formattedNextReviewDate: String`: 格式化的下次复习日期
- `needsReview: Bool`: 是否需要复习

### 新增的WordBookManager方法
- `getTodayReviewWords(limit: Int = 20)`: 获取今日复习单词
- `markWordReviewed(_:correct:)`: 标记单词复习状态
- `markWordsReviewed(_:)`: 批量标记复习状态
- `updateAllLearningPlans()`: 更新所有学习计划
- `getReviewStatistics()`: 获取复习统计
- `getUpcomingReviewPlan(days: Int = 7)`: 获取未来复习计划

## 数据模型关系
```
WordModel (扩展后)
├── 基础字段: id, word, imageData, targetLanguage, etc.
├── 学习字段: masteryLevel, notes
└── 学习计划字段:
    ├── nextReviewDate: Date
    ├── reviewInterval: Int
    ├── lastReviewDate: Date?
    ├── reviewCount: Int
    └── needsReview: Bool (计算属性)

ReviewStatistics (新增)
├── todayReviewCount: Int
├── correctCount: Int
├── incorrectCount: Int
├── accuracyRate: Double
├── pendingReviewCount: Int
├── totalWordsCount: Int
├── masteredWordsCount: Int
└── formattedAccuracyRate: String (计算属性)
```

## 测试验证
- ✅ Xcode编译验证通过（iPhone 17模拟器）
- ✅ SwiftData模型扩展正确
- ✅ 学习计划算法逻辑验证
- ✅ 数据查询和排序功能正常
- ✅ 编译无错误或警告

## 下一步计划
为下一个迭代做准备：
1. **学习计划UI界面**：创建用户友好的复习界面
2. **复习卡片组件**：实现单词复习的卡片式UI
3. **学习进度可视化**：图表展示学习进度和统计
4. **复习提醒功能**：基于本地通知的复习提醒

## 技术特点
- **零配置**：用户无需手动设置，系统自动管理学习计划
- **科学间隔**：基于艾宾浩斯遗忘曲线的简化算法
- **自动化管理**：复习后自动更新所有相关数据
- **灵活统计**：多维度展示学习进度和效果
- **高效查询**：优化的SwiftData查询性能

## 用户体验优化
- **简单易用**：只需点击"认识"/"不认识"即可完成复习
- **智能提醒**：自动计算最佳复习时间
- **进度可视化**：清晰展示学习进度和成就
- **个性化调整**：根据用户表现动态调整复习计划
//
//  BackgroundRefreshManager.swift
//  AINote
//
//  Created by 彭瑞淋 on 2024/10/29.
//

import Foundation
import BackgroundTasks
import WidgetKit
import AppRepository

// 调试代码  e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.AINote.reminder.refresh"]

class BackgroundRefreshManager {
    static let shared = BackgroundRefreshManager()
    
    private let notification = "kReminderRefreshDataNotification"

    // 后台任务标识符
    private let backgroundTaskIdentifier = "com.AINote.reminder.refresh"
    
    func registerBackgroundTask() {
//        // 注册后台任务
//        BGTaskScheduler.shared.register(
//            forTaskWithIdentifier: backgroundTaskIdentifier,
//            using: nil
//        ) { task in
//            if let refreshTask = task as? BGAppRefreshTask {
//                self.handleBackgroundRefresh(task: refreshTask)
//            } else {
//                task.setTaskCompleted(success: true)
//            }
//        }
//        
//        NotificationCenter.default.addObserver(forName: .init(rawValue: notification), object: nil, queue: nil) { _ in
//            Task {
//                await ReminderWidgetManager.shared.prepareWidgetData()
//            }
//            
//        }
    }
    
    func scheduleBackgroundRefresh() {
//        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: backgroundTaskIdentifier)
//        
//        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
//        // 设置最早执行时间（例如：12小时执行一次）
//        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600 * 12)
//        
//        do {
//            try BGTaskScheduler.shared.submit(request)
//        } catch {
//            print("无法安排后台任务: \(error)")
//        }
    }
    
    private func handleBackgroundRefresh(task: BGAppRefreshTask) {
//        // 创建一个任务完成的标记
//        let queue = OperationQueue()
//        queue.maxConcurrentOperationCount = 1
//        
//        // 设置任务过期处理
//        task.expirationHandler = {
//            queue.cancelAllOperations()
//        }
//        
//        // 添加数据刷新操作
//        let operation = RefreshOperation()
//        operation.completionBlock = {
//            // 完成后安排下一次刷新
//            self.scheduleBackgroundRefresh()
//            task.setTaskCompleted(success: !operation.isCancelled)
//        }
//        
//        queue.addOperation(operation)
    }
}

// 数据刷新操作
class RefreshOperation: Operation, @unchecked Sendable {
    override func main() {
        // 检查是否已取消
        guard !isCancelled else { return }
        
        // 执行数据刷新
        Task {
            await refreshData()
        }
    }
    
    @MainActor
    private func refreshData() async {
//        await MyPlantManager.shared.updatePlantWhichHasReminder()        
    }
}

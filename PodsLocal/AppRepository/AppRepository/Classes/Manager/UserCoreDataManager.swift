//
//  UserCoreDataManager.swift
//  AppRepository
//
//  Created by user on 2024/10/25.
//

import Foundation
import GLMP
import GLCore
import GLAccountExtension


//用于用户切换，本地数据库中数据的清理和更新
public class UserCoreDataManager {
    
    public static let shared = UserCoreDataManager()
    
    private init() {
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(GLMediator.kUserDeleteNotification), object: nil, queue: .main) { [weak self] notification in
            guard let self = self else { return }
            self.onUserChangedNofification()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(GLMediator.kUserChangedNotification), object: nil, queue: .main) { [weak self] notification in
            guard let self = self else { return }
            self.onUserChangedNofification()
        }
    }
    
    private func onUserChangedNofification() {
        removeUserCoreData()
        refreshUserCoreData(force: true)
    }
    
    public func removeUserCoreData() {
        DBManager.clearDababase()
    }
    
    public func refreshUserCoreData(force: Bool) {
//        SnapHistoryManager.shared.list(force: force)
//        MyPlantManager.shared.list(force: force)
//        DiagnoseHistoryManager.shared.list(force: force) { }
    }
    
    public func launchLoad() {
//        SnapHistoryManager.shared.list(force: false)
//        MyPlantManager.shared.list(force: false)
    }
}

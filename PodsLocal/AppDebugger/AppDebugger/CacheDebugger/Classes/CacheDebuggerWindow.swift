//
//  CacheDebuggerWindow.swift
//  CacheDebugger
//
//  Created by xie.longyan on 2022/9/2.
//

import Foundation
import DGMessageAPI
import GLDebugger
import GLUtils
import GLWidget
import GLDatabase
import GLCore
import GLConfig_Extension
import GLAccountExtension
import AdSupport
import GLConfig
import AppRepository

enum Feature: String, CaseIterable {
    case userId = "UserId"
    case idfa = "IDFA"
    case removeAllKeychain = "Keychain - Remove All"
    case removeAllKeychainAndAppCache = "Keychain & App Cache - Remove All"
    case removeSandbox = "Sandbox - Remove All"
    case deleteAccount = "Delete Account"
    
    var value: String {
        switch self {
        case .userId:
            return self.rawValue + ": " + (GL().Account_GetUserId() ?? "NULL")
        case .idfa:
            return self.rawValue + ": " + CacheDebuggerWindow.idfa
        case .removeAllKeychain: fallthrough
        case .removeAllKeychainAndAppCache: fallthrough
        case .removeSandbox: fallthrough
        case .deleteAccount:
            return self.rawValue
        }
    }
}

@objc public class CacheDebuggerWindow: GLDebuggerPluginWindow {
    
    var items: [Feature] = Feature.allCases
    
    public init() {
        
        super.init(config: .init(style: .fullScreen))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func createSubViews() {
        super.createSubViews()
        
        navigationView.title = "Cache Action"
        navigationView.addRightItems([closeButton])
        
        contentView.addSubview(tableView)
    }
    
    public override func setConstraint() {
        super.setConstraint()
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    
    static var idfa: String = ASIdentifierManager.shared().advertisingIdentifier.uuidString
    
    // MARK: - Lazy Load
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.backgroundColor = .white
        view.delegate = self
        view.dataSource = self
        view.estimatedRowHeight = 0
        view.estimatedSectionFooterHeight = 0
        view.estimatedSectionHeaderHeight = 0
        view.contentInsetAdjustmentBehavior = .never
        let height = self.config.style == .fullScreen ? GLDebugger.safeBottom : 0
        view.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: height))
        return view
    }()
}


extension CacheDebuggerWindow: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.gl_dequeueCell(with: UITableViewCell.self, for: indexPath)
        let item = items[indexPath.row]
        var text = items[indexPath.row].value
        cell.textLabel?.text = text
        cell.textLabel?.textColor = .black
        cell.textLabel?.font = .regular(16)
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = .white
        return cell
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = items[indexPath.row]
        handle(type)
    }
}


extension CacheDebuggerWindow {
    
    func handle(_ type: Feature) {
        switch type {
        case .userId:
            UIPasteboard.general.string = GL().Account_GetUserId()
            GLToast.showSuccess("Copied", in: self)
            
        case .idfa:
            UIPasteboard.general.string = Self.idfa
            GLToast.showSuccess("Copied", in: self)
            
        case .removeAllKeychain:
            GLKeyChain.removeAllItems()
            GLToast.showSuccess("Success", in: self)
            exit(0)
            
        case .removeAllKeychainAndAppCache:
            GLCache.removeAllObjects(sync: true)
            GL().WebImage_ClearCache()
            GLKeyChain.removeAllItems()
            GLToast.showSuccess("Success", in: self)
            exit(0)
            
        case .removeSandbox:
            // 清理 Document, Cache 和 Temporary 目录
            let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let cacheDirectoryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
            let temporaryDirectoryPath = NSTemporaryDirectory()
            cleanDirectories(directoryPaths: [documentDirectoryPath, cacheDirectoryPath, temporaryDirectoryPath])
            GLToast.showSuccess("Success", in: self)
            exit(0)
            
        case .deleteAccount:
            let alert = UIAlertController(title: "Confirm Delete Account?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default))
            alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { [weak alert] (_) in
                GLToast.showLoading()
                GL().Account_DeleteAccount { isSuccess, error in
                    if (isSuccess) {
                        UserCoreDataManager.shared.removeUserCoreData()
                        GL().Account_SetAccessToken(nil)
                        GL().Account_SetUser(nil)
                        GLToast.showSuccess("Success", in: self)
                        exit(0)
                    } else {
                        GLToast.showError("Delete failed.", in: self)
                    }
                }
            }))
            alert.gl_show()
        }
    }
}

extension CacheDebuggerWindow {
    func cleanDirectories(directoryPaths: [String]) {
        let fileManager = FileManager.default

        for directoryPath in directoryPaths {
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: directoryPath), includingPropertiesForKeys: nil)
                
                for fileURL in fileURLs {
                    try fileManager.removeItem(at: fileURL)
                }
            } catch {
                print("Error while cleaning directory at \(directoryPath): \(error)")
            }
        }
    }
}

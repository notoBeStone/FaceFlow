//
//  AppServerHostDebuggerWindow.swift
//  AppServerHostDebugger
//
//  Created by xie.longyan on 2022/9/2.
//

import Foundation
import GLDebugger
import GLUtils
import GLWidget

@objc public class AppServerHostDebuggerWindow: GLDebuggerPluginWindow {
    
    public init() {
        super.init(config: .init(style: .fullScreen))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func createSubViews() {
        super.createSubViews()
        
        navigationView.title = "App Server Host"
        navigationView.addLeftItem(addButton)
        navigationView.addRightItems([closeButton])
        
        contentView.addSubview(tableView)
    }
    
    public override func setConstraint() {
        super.setConstraint()
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    
    @objc func addButtonClick() {
        let alert = UIAlertController(title: "Add Custom Host", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "https://..."
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields?[0], let text = textField.text else {
                GLToast.showError("请正确添加Host", in: self)
                return
            }
            AppServerHostDebugger.shared.appendCustomHostModel(.init(type: .custom, title: "Custom", host: text, env: .stage))
            self.tableView.reloadData()
        }))
        alert.gl_show()
    }
    
    // MARK: - Lazy Load
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.backgroundColor = .white
        view.delegate = self
        view.dataSource = self
        if #available(iOS 11.0, *) {
            view.estimatedRowHeight = 0
            view.estimatedSectionFooterHeight = 0
            view.estimatedSectionHeaderHeight = 0
            view.contentInsetAdjustmentBehavior = .never
        }
        let height = self.config.style == .fullScreen ? GLDebugger.safeBottom : 0
        view.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: height))
        return view
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton(title: "Add", color: .black, font: .regular(16.0))
        button.addTarget(self, action: #selector(addButtonClick), for: .touchUpInside)
        return button
    }()
}


extension AppServerHostDebuggerWindow: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let models = AppServerHostDebugger.shared.hostModels
        return models.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.gl_dequeue(for: tableView, for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .white
        let model = AppServerHostDebugger.shared.hostModels[indexPath.row]
        cell.textLabel?.text = model?.info
        if let model = model, model.isSelected {
            cell.textLabel?.textColor = .themeColor
            cell.textLabel?.font = .semibold(14.0)
        } else {
            cell.textLabel?.textColor = .black
            cell.textLabel?.font = .regular(14.0)
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let model = AppServerHostDebugger.shared.hostModels[indexPath.row] {
                AppServerHostDebugger.shared.delete(model)
                self.tableView.reloadData()
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let model = AppServerHostDebugger.shared.hostModels[indexPath.row],
           model.host != AppServerHostDebugger.shared.selectedHostModel?.host {
            AppServerHostDebugger.shared.select(model)
        }
        self.tableView.reloadData()
    }
}

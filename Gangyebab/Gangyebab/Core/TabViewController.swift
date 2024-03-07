//
//  TabViewController.swift
//  Gangyebab
//
//  Created by 이동현 on 3/7/24.
//

import UIKit

enum TabBarItemType: Int {
    case home
    case setting
}

extension TabBarItemType {
    func setTabBarItem() -> UITabBarItem {
        return UITabBarItem(
            title: "",
            image: .actions,
            selectedImage: .add
        )
    }
}

final class TabViewController: UITabBarController {

    private var tabs: [TabBarItemType: UIViewController] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setTabBarItems() {
        tabs = [
            .home: HomeViewController(),
            .setting: SettingViewController()
        ]
        
        tabs.forEach { type, viewController in
            viewController.tabBarItem = type.setTabBarItem()
        }
        
        let viewControllers = tabs
            .sorted { $0.key.rawValue < $1.key.rawValue }
            .compactMap { $0.value }
        
        setViewControllers(viewControllers, animated: false)
    }
}

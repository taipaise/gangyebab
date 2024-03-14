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
    var description: String {
        switch self {
        case .home:
            return "홈"
        case .setting:
            return "설정"
        }
    }
    
    var image: UIImage {
        switch self {
        case .home:
            return UIImage(systemName: "house.fill")!
        case .setting:
            return UIImage(systemName: "gearshape.fill")!
        }
    }
    
    func setTabBarItem() -> UITabBarItem {
        return UITabBarItem(
            title: description,
            image: image,
            selectedImage: image
        )
    }
}

final class TabViewController: UITabBarController {

    private var tabs: [TabBarItemType: UIViewController] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTabBarItems()
        setUI()
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
    
    private func setUI() {
        let fontAttributes = [NSAttributedString.Key.font: UIFont.omyu(size: 13)]
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)
        
        tabBar.backgroundColor = .background2
        tabBar.tintColor = .point1
        tabBar.layer.cornerRadius = 20
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}

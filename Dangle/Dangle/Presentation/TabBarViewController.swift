//
//  TabBarViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/07.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Each Tab Main ViewControllers
        let vc1 = HomeViewController()
        let vc2 = MapViewController()
        let vc3 = ProfileViewController()
        
        // Setting Title
        vc1.title = "Home"
        vc2.title = "Map"
        vc3.title = "Profile"
        
        // navigationItem Title
        vc1.navigationItem.largeTitleDisplayMode = .always
        vc2.navigationItem.largeTitleDisplayMode = .always
        vc3.navigationItem.largeTitleDisplayMode = .always
        
        // Setting to RootView
        let nav1 = UINavigationController(rootViewController: vc1)
        let nav2 = UINavigationController(rootViewController: vc2)
        let nav3 = UINavigationController(rootViewController: vc3)
        
        // TabBarItem Setting
        nav1.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "우리 동네", image: UIImage(systemName: "map"), tag: 2)
        nav3.tabBarItem = UITabBarItem(title: "내 정보", image: UIImage(systemName: "person"), tag: 3)
        
        
        // MARK: - 임시로 Large title 설정 (추후 변경)
        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true
        
        nav1.navigationBar.tintColor = .label
        nav2.navigationBar.tintColor = .label
        nav3.navigationBar.tintColor = .label
        
        // Arrange Each NavigationController
        setViewControllers([nav1, nav2, nav3], animated: true)
    }
}

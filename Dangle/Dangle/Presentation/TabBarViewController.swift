//
//  TabBarViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/07.
//

import UIKit

class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Each Tab Main ViewControllers
        let vc1 = HomeViewController()
        let vc2 = MapViewController()
        let vc3 = ProfileViewController()

        // set title
        vc1.title = "Home"
        vc2.title = "Search"
        vc3.title = "Library"

        vc1.navigationItem.largeTitleDisplayMode = .never
        vc2.navigationItem.largeTitleDisplayMode = .never
        vc3.navigationItem.largeTitleDisplayMode = .never
        
        // Setting to RootView
        let nav1 = UINavigationController(rootViewController: vc1)
        let nav2 = UINavigationController(rootViewController: vc2)
        let nav3 = UINavigationController(rootViewController: vc3)
        
        // TabBarItem Setting
        nav1.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "우리 동네", image: UIImage(systemName: "map"), tag: 2)
        nav3.tabBarItem = UITabBarItem(title: "내 정보", image: UIImage(systemName: "person"), tag: 3)


        nav1.navigationBar.prefersLargeTitles = false
        nav2.navigationBar.prefersLargeTitles = false
        nav3.navigationBar.prefersLargeTitles = false

        nav1.navigationBar.tintColor = .label
        nav2.navigationBar.tintColor = .label
        nav3.navigationBar.tintColor = .label

        // Arrange Each NavigationController
        setViewControllers([nav1, nav2, nav3], animated: true)

        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
}

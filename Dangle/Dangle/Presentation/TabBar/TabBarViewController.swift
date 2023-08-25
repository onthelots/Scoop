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

        let vc1 = HomeViewController()
        let vc2 = MapViewController()
        let vc3 = ProfileViewController()
        vc1.navigationItem.largeTitleDisplayMode = .always
        vc2.navigationItem.largeTitleDisplayMode = .always
        vc3.navigationItem.largeTitleDisplayMode = .always

        vc1.title = "Home"
        vc2.title = "Dangle\nMap"
        vc3.title = "Profile"

        // nav들은, UINavigationController(Stack기반)이며, rootView는 각각의 viewController로 설정함
        let nav1 = UINavigationController(rootViewController: vc1)
        let nav2 = UINavigationController(rootViewController: vc2)
        let nav3 = UINavigationController(rootViewController: vc3)
        
        // 각각의 UINavigationController의 속성을 설정함
        nav1.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "우리 동네", image: UIImage(systemName: "map"), tag: 2)
        nav3.tabBarItem = UITabBarItem(title: "내 정보", image: UIImage(systemName: "person"), tag: 3)

        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true

        nav1.navigationBar.tintColor = .label
        nav2.navigationBar.tintColor = .label
        nav3.navigationBar.tintColor = .label

        // Arrange Each NavigationController
        setViewControllers([nav1, nav2, nav3], animated: false)

        // 중복문제 피하기
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = tabBarController
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
}

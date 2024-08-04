//
//  AppDelegate.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/04.
//

import UIKit
import Firebase
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        let window = UIWindow(frame: UIScreen.main.bounds)

        if let savedUserEmail = UserDefaultStorage<String>().getCached(key: "email"),
            let savedUserPassword = UserDefaultStorage<String>().getCached(key: "password") {
             // 키체인에 useremail, userPassword 가 존재할 경우
             let signInUseCase = DefaultSignInUseCase(authRepository: DefaultsAuthRepository())
             let emailValidationService = DefaultEmailValidationService()
             let viewModel = SignInViewModel(signInUseCase: signInUseCase, emailValidationService: emailValidationService)
             viewModel.login(email: savedUserEmail, password: savedUserPassword)

             let tabBarController = TabBarViewController()
             tabBarController.selectedIndex = 0
             window.rootViewController = tabBarController
         } else {
             let navVC = UINavigationController(rootViewController: StartPageViewController())
             window.rootViewController = navVC
         }

        // MARK: - UITabBarAppearance 설정 (앱 전역)
        let uiTabBarappearance = UITabBarAppearance()
        let tabBar = UITabBar()
        uiTabBarappearance.configureWithOpaqueBackground()
        uiTabBarappearance.backgroundColor = .systemBackground

        // icon Color (UITabBarItem)
        uiTabBarappearance.stackedLayoutAppearance.selected.iconColor = .systemGray2

        // title tint color
        uiTabBarappearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
        tabBar.standardAppearance = uiTabBarappearance
        tabBar.scrollEdgeAppearance = uiTabBarappearance

        UITabBar.appearance().standardAppearance = uiTabBarappearance
        UITabBar.appearance().scrollEdgeAppearance = tabBar.scrollEdgeAppearance

        // 상단 네비게이션 바 (View)
        // titleView 부분의 별도의 View를 설정하지 않을 경우, clear 색상을 통해 투명하게 설정할 것
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.backgroundColor = .clear
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance

        // set key window
        window.makeKeyAndVisible()
        self.window = window

        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}

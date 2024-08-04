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
        // set key window
        window.makeKeyAndVisible()
        self.window = window

        let appearance = UITabBarAppearance()
        let tabBar = UITabBar()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground

        tabBar.standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance

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

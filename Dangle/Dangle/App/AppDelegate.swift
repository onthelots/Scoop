//
//  AppDelegate.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/04.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        //        KakaoSDK.initSDK(appKey: "3b61d69dccfeedfdc824b3a7e958633d")
        FirebaseApp.configure()

        let window = UIWindow(frame: UIScreen.main.bounds)

        if let savedUserEmail = SensitiveInfoManager.read(key: "userEmail"),
           let savedUserPassword = SensitiveInfoManager.read(key: "userPassword") {
            // 키체인에 useremail, userPassword 가 존재할 경우
            let authRepository = DefaultsAuthRepository()
            let signInUseCase = DefaultSignInUseCase(authRepository: authRepository)
            let viewModel = SignInViewModel(signInUseCase: signInUseCase)
            viewModel.login(email: savedUserEmail, password: savedUserPassword) // 로그인을 알아서 실시함 (자동 로그인을 계속 지속하며, 로그아웃 혹은 앱을 삭제시키기 전까지 로그인 상태를 유지함)
            
            window.rootViewController = TabBarViewController() // 루트뷰를 TabBarViewController로 변경시킴
        } else {
            // 키체인에 useremail, userPassword 가 없는 경우, rootView를 startPageViewController로 변경시킴
            let navVC = UINavigationController(rootViewController: StartPageViewController())
            window.rootViewController = navVC
        }
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
}

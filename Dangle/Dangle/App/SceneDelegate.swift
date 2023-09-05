//
//  SceneDelegate.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/04.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)

        // 키체인에 저장되어 있다면
        if let savedUserEmail = UserDefaultStorage<String>().getCached(key: "email"),
            let savedUserPassword = UserDefaultStorage<String>().getCached(key: "password") {

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

        window.makeKeyAndVisible()
        self.window = window
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }
}

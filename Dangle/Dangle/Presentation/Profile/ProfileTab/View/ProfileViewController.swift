//
//  ProfileViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/07.
//

import Combine
import UIKit
import Firebase

class ProfileViewController: UIViewController {

    private var viewModel: ProfileViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        initalizerViewModel()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .done,
            target: self,
            action: #selector(didTapSetting)
        )
    }
    
    // viewModel 초기화
    private func initalizerViewModel() {
        let userInfoUseCase = DefaultsUserInfoUseCase(userInfoRepository: DefaultsUserInfoRepository())
        let postUseCase = DefaultPostUseCase(postRepository: DefaultPostRepository(networkManager: NetworkService(configuration: .default), geocodeManager: GeocodingManager(), firestore: Firestore.firestore()))
        viewModel = ProfileViewModel(userInfoUseCase: userInfoUseCase, postUseCase: postUseCase)
    }

    @objc func didTapSetting() {
        let viewController = SettingViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}

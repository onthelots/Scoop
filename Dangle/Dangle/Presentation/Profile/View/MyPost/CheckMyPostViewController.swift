//
//  CheckMyPostViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/12.
//

import Combine
import UIKit
import Firebase

class CheckMyPostViewController: UIViewController {

    private var viewModel: ProfileViewModel!
    let myPosts: [Post]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupBackButton()
        initalizerViewModel()
    }

    init(myPosts: [Post]) {
        self.myPosts = myPosts
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // viewModel 초기화
    private func initalizerViewModel() {
        let userInfoUseCase = DefaultsUserInfoUseCase(userInfoRepository: DefaultsUserInfoRepository())
        let postUseCase = DefaultPostUseCase(postRepository: DefaultPostRepository(networkManager: NetworkService(configuration: .default), geocodeManager: GeocodingManager(), firestore: Firestore.firestore()))
        viewModel = ProfileViewModel(userInfoUseCase: userInfoUseCase, postUseCase: postUseCase)
    }
}

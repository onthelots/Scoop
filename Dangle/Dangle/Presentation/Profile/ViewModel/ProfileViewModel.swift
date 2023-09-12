//
//  ProfileViewModel.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/11.
//

import Combine
import Foundation
import Firebase
import SafariServices

class ProfileViewModel: ObservableObject {
    private let userInfoUseCase: UserInfoUseCase
    private let postUseCase: PostUseCase

    @Published var isNicknameValid = false
    @Published var isDuplication = false
    @Published var isSignUpButtonEnabled = false

    @Published var userInfo: UserInfo!
    @Published var myPosts: [Post] = []

    let editProfileTapped = PassthroughSubject<UserInfo, Never>()
    let checkMyPostTapped = PassthroughSubject<[Post], Never>()

    private var subscription = Set<AnyCancellable>()

    init(userInfoUseCase: UserInfoUseCase, postUseCase: PostUseCase) {
        self.userInfoUseCase = userInfoUseCase
        self.postUseCase = postUseCase
        userInfoFetch()
    }

    func userInfoFetch() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        userInfoUseCase.getUserInfo(userId: userId) { result in
            switch result {
            case .success(let userInfo):
                self.userInfo = userInfo
                self.postUseCase.fetchUserPosts(uid: userId) { posts in
                    switch posts {
                    case .success(let myPosts):
                        self.myPosts = myPosts
                        print("내 포스트 : \(myPosts.count)")
                    case .failure(let error):
                        print("error: \(error)")
                    }
                }
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }
}

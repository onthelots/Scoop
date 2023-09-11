//
//  ProfileViewModel.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/11.
//

import Combine
import Foundation
import Firebase

class ProfileViewModel: ObservableObject {
    private let userInfoUseCase: UserInfoUseCase
    private let postUseCase: PostUseCase

    @Published var userInfo: UserInfo!

    init(userInfoUseCase: UserInfoUseCase, postUseCase: PostUseCase) {
        self.userInfoUseCase = userInfoUseCase
        self.postUseCase = postUseCase
    }

    func userInfoFetch() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        userInfoUseCase.getUserInfo(userId: userId) { result in
            switch result {
            case .success(let userInfo):
                self.userInfo = userInfo
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }
}

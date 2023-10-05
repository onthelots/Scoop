//
//  ProfileViewModel.swift
//  Scoop
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
    @Published var filteredMyPostForCategory: [Post] = []
    @Published var items: [ProfileTableItem] = []

    let myPostCategoryTapped = CurrentValueSubject<PostCategory, Never>(PostCategory.restaurant)

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
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }

    // 내 포스팅 불러오기(+카테고리 별 쿼리)
    func fetchMyPosts(category: PostCategory) {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        postUseCase.fetchUserPosts(uid: userId, category: category) { [weak self] result in
            switch result {
            case .success(let posts):
                self?.filteredMyPostForCategory = posts
            case .failure(let error):
                print("Error fetching posts around coordinate: \(error)")
            }
        }
    }

    // 테이블 뷰 초기화
    func fetchProfileTableView() {
        items = [
            ProfileTableItem(title: "약관 확인", action: .openURL("https://www.notion.so/onthelots/72f35ba1c5b14c919ac3a7016840e79d?pvs=4")),
            ProfileTableItem(title: "자주 찾는 질문", action: .openURL("https://www.notion.so/onthelots/Q-A-8a07aa6f15614e318e210430a54c421a?pvs=4")),
            ProfileTableItem(title: "앱 소개", action: .openURL("https://www.notion.so/onthelots/32eb5fa184c14426a4f32b654f76ec0e?v=96817719164f49e398abae2bc4c8565c&pvs=4")),
            ProfileTableItem(title: "로그아웃", action: .showAlert)
        ]
    }

    func deletePost(post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        postUseCase.deletePost(storeName: post.storeName, nickname: post.nickname) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // 첫 화면에서 나타날 초기값
    func initializerFetchMyPosts(category: PostCategory) {
        fetchMyPosts(category: category)
    }
}

// MARK: - ProfileTableUtem Struct
struct ProfileTableItem {
    let title: String
    let action: ProfileAction

    enum ProfileAction {
        case openURL(String)
        case showAlert
    }
}

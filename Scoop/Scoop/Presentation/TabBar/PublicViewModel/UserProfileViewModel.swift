//
//  UserProfileViewModel.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 8/4/24.
//

import FirebaseAuth
import AuthenticationServices
import Combine
import Foundation
import Realm

class UserProfileViewModel {
    private let userInfoUseCase: UserInfoUseCase

    @Published var currentUserInfo: UserInfo?


    // MARK: - 해당 정보는 RealmDB에 저장해서 사용할 것
    // Fetch 빈도를 최대한 줄여야 함

    init(userInfoUseCase: UserInfoUseCase) {
        self.userInfoUseCase = userInfoUseCase
    }

    // MARK: - 유저 정보 파싱 (Server + DB 저장)
    func updateUserInfo(userId: String, completion: @escaping (Result<UserInfo, Error>) -> Void) {
        self.userInfoUseCase.getUserInfo(userId: userId) { result in
            switch result {
            case .success(let updateUserInfo):
                let realm = RealmManager.shared.realm(forStorageName: "\(userId)")

                do {
                    try realm.write {
                        if let currentUserInfoFromDB = realm.objects(RealmUserInfo.self).first {

                            // TODO: - DB 업데이트

                        } else {
                            // 새로운 객체 추가
                            let realmUserInfo = RealmUserInfo()
                            realm.add(realmUserInfo)
                        }
                        completion(.success(updateUserInfo))
                    }
                } catch {
                    print("로컬 DB 사용자 정보 저장 실패 : \(error)")
                    completion(.failure(error))
                }

            case .failure(let failure):
                print("로컬 DB 유저정보 저장 실패 : \(failure)")
                completion(.failure(failure))
            }
        }
    }
}

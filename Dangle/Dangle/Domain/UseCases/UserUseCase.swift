//
//  UserUseCase.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import Foundation

protocol UserInfoUseCase {
    func getUserInfo(
        userId: String,
        completion: @escaping (Result<UserInfo, Error>) -> Void
    )

    func updateNickname(
        uid: String,
        newNickname: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )

    func updateEmail(
        uid: String,
        newEmail: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class DefaultsUserInfoUseCase: UserInfoUseCase {
    private let userInfoRepository: UserInfoRepository
    init(userInfoRepository: UserInfoRepository) {
        self.userInfoRepository = userInfoRepository
    }

    func getUserInfo(
        userId: String,
        completion: @escaping (Result<UserInfo, Error>) -> Void
    ) {
        userInfoRepository.getUserInfo(userId: userId) { result in
            switch result {
            case .success(let info):
                completion(.success(info))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func updateNickname(
        uid: String,
        newNickname: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        userInfoRepository.updateNickname(
            uid: uid,
            newNickname: newNickname,
            completion: completion
        )
    }

    func updateEmail(
        uid: String,
        newEmail: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        userInfoRepository.updateEmail(
            uid: uid,
            newEmail: newEmail,
            completion: completion
        )
    }
}

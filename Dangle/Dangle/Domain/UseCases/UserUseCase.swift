//
//  UserUseCase.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import Foundation

protocol UserInfoUseCase {
    func execute(
        userId: String,
        completion: @escaping (Result<UserInfo, Error>) -> Void
    )
}

final class DefaultsUserInfoUseCase: UserInfoUseCase {
    private let userInfoRepository: UserInfoRepository
    init(userInfoRepository: UserInfoRepository) {
        self.userInfoRepository = userInfoRepository
    }

    func execute(
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
}

//
//  UserInfoRepository.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import Foundation

protocol UserInfoRepository {
    func getUserInfo(userId: String, completion: @escaping (Result<UserInfo, Error>) -> Void)
}

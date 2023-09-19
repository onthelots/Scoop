//
//  UserInfoRepository.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import Foundation

protocol UserInfoRepository {
    func getUserInfo(userId: String, completion: @escaping (Result<UserInfo, Error>) -> Void)
    func updateNickname(uid: String, newNickname: String, completion: @escaping (Result<Void, Error>) -> Void)
    func updateEmail(uid: String, newEmail: String, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteUser(completion: @escaping (Result<Void, Error>) -> Void)
}

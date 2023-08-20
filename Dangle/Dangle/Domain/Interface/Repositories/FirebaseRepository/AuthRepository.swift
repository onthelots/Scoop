//
//  AuthRepository.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/18.
//

import Foundation
import FirebaseAuth

protocol AuthRepository {
    func checkEmail(email: String, completion: @escaping (Result<Bool, Error>) -> Void)
    func checkNickname(nickname: String, completion: @escaping (Result<Bool, Error>) -> Void)
    func signUp(email: String, password: String, location: String, nickname: String, completion: @escaping (Result<Void, Error>) -> Void) // 이메일, 비밀번호 저장
}

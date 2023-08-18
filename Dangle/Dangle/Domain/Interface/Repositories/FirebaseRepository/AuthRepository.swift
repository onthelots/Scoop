//
//  AuthRepository.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/18.
//

import Foundation
import FirebaseAuth

protocol AuthRepository {
    func signUp(email: String, password: String, location: String, completion: @escaping (Result<AuthUser, Error>) -> Void) // 이메일, 비밀번호 저장
}

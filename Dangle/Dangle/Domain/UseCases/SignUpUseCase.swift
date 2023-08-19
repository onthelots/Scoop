//
//  SignUpUseCase.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/18.
//

import Foundation
import FirebaseAuth

protocol SignUpUseCase {

    // 이메일 중복 검사
    func execute(
        email: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    )

    // 계정 등록하기
    func execute(
        email: String,
        password: String,
        location: String,
        nickname: String,
        completion: @escaping (Result<AuthUser, Error>) -> Void
    )
}

class DefaultSignUpUseCase: SignUpUseCase {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    // 이메일 중복검사
    func execute(email: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        authRepository.checkEmail(email: email) { result in
            switch result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // 계정 등록하기
    func execute(email: String, password: String, location: String, nickname: String, completion: @escaping (Result<AuthUser, Error>) -> Void) {
        authRepository.signUp(email: email, password: password, location: location, nickname: nickname) { result in
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

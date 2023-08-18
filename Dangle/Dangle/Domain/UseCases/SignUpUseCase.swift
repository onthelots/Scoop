//
//  SignUpUseCase.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/18.
//

import Foundation
import FirebaseAuth

protocol SignUpUseCase {

    // 계정 등록하기
    func execute(
        email: String,
        password: String,
        location: String,
        completion: @escaping (Result<AuthUser, Error>) -> Void
    )
}

class DefaultSignUpUseCase: SignUpUseCase {

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute(email: String, password: String, location: String, completion: @escaping (Result<AuthUser, Error>) -> Void) {
        authRepository.signUp(email: email, password: password, location: location) { result in
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

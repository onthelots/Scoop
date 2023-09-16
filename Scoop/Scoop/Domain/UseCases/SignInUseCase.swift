//
//  SignInUseCase.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/21.
//

import Foundation

protocol SignInUseCase {
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
}

class DefaultSignInUseCase: SignInUseCase {

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    // 로그인
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        authRepository.signIn(email: email, password: password) { result in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

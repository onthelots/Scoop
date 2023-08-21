//
//  SignInUseCase.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/21.
//

import Foundation

protocol SignInUseCase {
    func execute(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class DefaultSignInUseCase: SignInUseCase {

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        authRepository.signIn(email: email, password: password) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

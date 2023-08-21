//
//  SignInViewModel.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/21.
//

import Combine
import Foundation

class SignInViewModel: ObservableObject {

    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String?

    private var cancellables: Set<AnyCancellable> = []
    private let signInUseCase: SignInUseCase

    init(signInUseCase: SignInUseCase) {
        self.signInUseCase = signInUseCase
    }

    func login(email: String, password: String) {
        signInUseCase.execute(email: email, password: password) { [weak self] result in
            switch result {
            case .success:
                self?.isLoggedIn = true
                self?.errorMessage = nil // 성공 시 에러 메시지를 초기화
                print("로그인 성공")
            case .failure(let error):
                self?.isLoggedIn = false
                self?.errorMessage = error.localizedDescription
            }
        }
    }
}

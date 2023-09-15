//
//  SignInViewModel.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/21.
//

import Combine
import Foundation

class SignInViewModel: ObservableObject {
    private let signInUseCase: SignInUseCase
    private let emailValidationService: EmailValidationService

    @Published var isEmailValid: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String?

    let emailInput = PassthroughSubject<String, Never>()
    private var subscription: Set<AnyCancellable> = []


    init(signInUseCase: SignInUseCase, emailValidationService: EmailValidationService) {
        self.signInUseCase = signInUseCase
        self.emailValidationService = emailValidationService
    }

    func checkEmailValidAndSave() {
        emailInput
            .map { [weak self] email in
                return self?.emailValidationService.validateEmail(email) ?? false
            }
            .assign(to: \.isEmailValid, on: self)
            .store(in: &subscription)
    }

    func login(email: String, password: String) {
        signInUseCase.signIn(email: email, password: password) { [weak self] result in
            switch result {
            case .success:
                self?.isLoggedIn = true
                self?.errorMessage = nil // 성공 시 에러 메시지를 초기화
            case .failure:
                self?.isLoggedIn = false
                self?.errorMessage = "이메일/비밀번호가 일치하지 않습니다."
            }
        }
    }
}

//
//  RegPasswordViewModel.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/20.
//

import Combine
import FirebaseAuth

final class RegPasswordViewModel: ObservableObject {
    private let signUpUseCase: DefaultSignUpUseCase
    private let passwordValidationService: PasswordValidationService

    let passwordInput = PassthroughSubject<String, Never>()
    let confirmPasswordInput = PassthroughSubject<String, Never>()

    private var cancellables = Set<AnyCancellable>()

    @Published var password: String = ""
    @Published var isPasswordContainsLetter = false
    @Published var isPasswordContainsNumber = false
    @Published var isPasswordLengthValid = false
    @Published var isPasswordValid = false

    @Published var doPasswordsMatch = false
    @Published var isSignUpButtonEnabled = false

    init(signUpUseCase: DefaultSignUpUseCase, passwordValidationService: PasswordValidationService) {
        self.signUpUseCase = signUpUseCase
        self.passwordValidationService = passwordValidationService

        bindInputs()
        bindOutputs()
    }

    // MARK: - 비즈니스 로직을 여기서 처리할거야
    private func bindInputs() {

        passwordInput
            .map { [weak self] password in
                return self?.passwordValidationService.validatePassword(password) ?? false
            }
            .assign(to: \.isPasswordValid, on: self)
            .store(in: &cancellables)

        passwordInput
            .map { [weak self] password in
                return self?.passwordValidationService.validatePasswordContainsLetter(password) ?? false
            }
            .assign(to: \.isPasswordContainsLetter, on: self)
            .store(in: &cancellables)

        passwordInput
            .map { [weak self] password in
                return self?.passwordValidationService.validatePasswordContainsNumber(password) ?? false
            }
            .assign(to: \.isPasswordContainsNumber, on: self)
            .store(in: &cancellables)

        passwordInput
            .map { [weak self] password in
                return self?.passwordValidationService.validatePasswordLength(password) ?? false
            }
            .assign(to: \.isPasswordLengthValid, on: self)
            .store(in: &cancellables)

        Publishers.CombineLatest(passwordInput, confirmPasswordInput)
            .map { password, confirmPassword in
                return password == confirmPassword
            }
            .assign(to: \.doPasswordsMatch, on: self)
            .store(in: &cancellables)
    }

    private func bindOutputs() {
        Publishers.CombineLatest($isPasswordValid, $doPasswordsMatch)
            .map { isPasswordValid, doPasswordsMatch in
                return isPasswordValid && doPasswordsMatch
            }
            .assign(to: \.isSignUpButtonEnabled, on: self)
            .store(in: &cancellables)
    }

    // 패스워드 넘기기
    func setUserEmail(password: String) {
        self.password = password
     }
}

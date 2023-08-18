//
//  SignUpViewModel.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/18.
//

import UIKit
import Combine
import FirebaseAuth

class SignUpViewModel: ObservableObject {
    private let signUpUseCase: DefaultSignUpUseCase
    private let emailValidationService: EmailValidationService
    private let passwordValidationService: PasswordValidationService

    // Input
    let emailInput = PassthroughSubject<String, Never>()
    let passwordInput = PassthroughSubject<String, Never>()
    let confirmPasswordInput = PassthroughSubject<String, Never>()
    @Published var users: [UserInfo] = []

    // Output
    @Published var isEmailValid = false

    @Published var isPasswordContainsLetter = false
    @Published var isPasswordContainsNumber = false
    @Published var isPasswordLengthValid = false
    @Published var isPasswordValid = false

    @Published var doPasswordsMatch = false
    @Published var isSignUpButtonEnabled = false

    let itemTapped = PassthroughSubject<UserInfo, Never>()

    private var cancellables = Set<AnyCancellable>()

    init(signUpUseCase: DefaultSignUpUseCase, emailValidationService: EmailValidationService, passwordValidationService: PasswordValidationService) {
        self.signUpUseCase = signUpUseCase
        self.emailValidationService = emailValidationService
        self.passwordValidationService = passwordValidationService

        bindInputs()
        bindOutputs()
    }

    private func bindInputs() {
          emailInput
              .map { [weak self] email in
                  return self?.emailValidationService.validateEmail(email) ?? false
              }
              .assign(to: \.isEmailValid, on: self)
              .store(in: &cancellables)

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
        Publishers.CombineLatest3($isEmailValid, $isPasswordValid, $doPasswordsMatch)
            .map { isEmailValid, isPasswordValid, doPasswordsMatch in
                return isEmailValid && isPasswordValid && doPasswordsMatch
            }
            .assign(to: \.isSignUpButtonEnabled, on: self)
            .store(in: &cancellables)
    }

    // FireAuth에 저장하기
    func checkEmailExistsAndSignUp(email: String, password: String, location: String) {
        signUpUseCase.execute(email: email, password: password, location: location) { results in
            switch results {
            case .success(let result):
                self.users = result.user
                print("--> UserCase 메서드가 실행되었습니다 저장된 값은 : \(self.users)")
            case .failure(let error):
                print("--> UseCase 메서드가 실패하였습니다: \(error)")
            }
        }
    }
}

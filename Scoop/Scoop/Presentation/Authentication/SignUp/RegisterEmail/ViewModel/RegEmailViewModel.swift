//
//  RegEmailViewModel.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/19.
//

import Combine
import FirebaseAuth
import UIKit

class RegEmailViewModel: ObservableObject {
    private let signUpUseCase: DefaultSignUpUseCase
    private let emailValidationService: EmailValidationService

    // MARK: - Input
    @Published var isEmailValid: Bool = false // 이메일 유효혀부 확인 (EmailValidationService)
    @Published var isDuplication: Bool = false // 이메일 중복여부 확인
    @Published var email: String = ""

    // MARK: - Output
    let emailInput = PassthroughSubject<String, Never>()

    private var subscription = Set<AnyCancellable>()

    init(signUpUseCase: DefaultSignUpUseCase, emailValidationService: EmailValidationService) {
        self.signUpUseCase = signUpUseCase
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

    // 이메일 설정
    func setUserEmail(email: String) {
        self.email = email
     }

    // Checked Dubplication
    func checkEmailDuplication(email: String, completion: @escaping (Bool) -> Void) {
            signUpUseCase.checkEmail(email: email) { [weak self] result in
                switch result {
                case .success(let isDuplicated):
                    print("이메일 중복여부 : \(isDuplicated)")
                    completion(isDuplicated)
                case .failure:
                    self?.isEmailValid = false
                    print("이메일이 중복됩니다.")
                    completion(false)
                }
            }
        }
}

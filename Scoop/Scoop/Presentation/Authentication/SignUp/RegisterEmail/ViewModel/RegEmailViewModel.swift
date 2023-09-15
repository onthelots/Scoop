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

    // Input
    @Published var isEmailValid: Bool = false // 이메일 유효혀부 확인 (EmailValidationService)
    @Published var isDuplication: Bool = false // 이메일 중복여부 확인
    // 사용자 정보
    @Published var email: String = ""

    // Output
    let emailInput = PassthroughSubject<String, Never>() // 외부에서도 일련의 값을 전달할 수 있음
    let validEmailInput = PassthroughSubject<String, Never>() // 외부에서도 일련의 값을 전달할 수 있음

    private var subscription = Set<AnyCancellable>()

    init(signUpUseCase: DefaultSignUpUseCase, emailValidationService: EmailValidationService) {
        self.signUpUseCase = signUpUseCase
        self.emailValidationService = emailValidationService
    }

    // -----> 값을 받아옴 ---> 2. 이메일 유효성 여부 검사를 실시하고 -> 해당 결과값을 isEmailValid에 할당함
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
    func executeEmailDuplicationCheck(email: String, completion: @escaping (Bool) -> Void) {
            signUpUseCase.checkEmail(email: email) { [weak self] result in
                switch result {
                case .success(let isDuplicated):
                    print("이메일 중복여부 : \(isDuplicated)")
                    completion(isDuplicated)
                case .failure:
                    self?.isEmailValid = false
                    print("문제가 발생했습니다.")
                    completion(true)
                }
            }
        }
}

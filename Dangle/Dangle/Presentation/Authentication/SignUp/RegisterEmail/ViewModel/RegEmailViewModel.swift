//
//  RegEmailViewModel.swift
//  Dangle
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
    let emailInput = PassthroughSubject<String, Never>() // 외부에서도 일련의 값을 전달할 수 있음
    @Published var userInfo: [UserInfo] = [] // 이메일 유효혀부 확인 (EmailValidationService)
    // Output
    @Published var isEmailValid = false // 이메일 유효혀부 확인 (EmailValidationService)
    @Published var isEmailDuplication = false // 이메일 중복여부 확인

    private var cancellables = Set<AnyCancellable>()

    init(signUpUseCase: DefaultSignUpUseCase, emailValidationService: EmailValidationService) {
        self.signUpUseCase = signUpUseCase
        self.emailValidationService = emailValidationService

        bindInputs()
        bindOutputs()
    }

    // 이메일 유효성 여부 검사 (Input / 퍼블리셔 emailInput -> map을 통해 값을 다시 할당함 -> assign을 통해 퍼블리셔 inEmailValid에 새로운 값을 할당)
    private func bindInputs() {
        emailInput
            .map { [weak self] email in
                return self?.emailValidationService.validateEmail(email) ?? false
            }
            .assign(to: \.isEmailValid, on: self)
            .store(in: &cancellables)
    }

    private func bindOutputs() {
            $isEmailValid
                .receive(on: RunLoop.main)
                .sink { [weak self] isValid in
                    if !isValid {
                        self?.isEmailDuplication = false // 이메일 유효성 검사 실패 시 중복 여부도 초기화
                    }
                }
                .store(in: &cancellables)
        }

    func executeEmailDuplicationCheck(email: String, completion: @escaping (Bool) -> Void) {
            signUpUseCase.execute(email: email) { [weak self] result in
                switch result {
                case .success(let isDuplicated):
                    self?.isEmailDuplication = isDuplicated
                    completion(isDuplicated)
                case .failure :
                    self?.isEmailDuplication = false
                    completion(false) // Assume duplication check failed
                }
            }
        }
}

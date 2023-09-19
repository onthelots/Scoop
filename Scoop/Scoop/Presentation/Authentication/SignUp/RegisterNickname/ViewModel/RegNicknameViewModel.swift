//
//  RegNicknameViewModel.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/20.
//

import Combine
import FirebaseAuth

final class RegNicknameViewModel: ObservableObject {
    internal let signUpUseCase: DefaultSignUpUseCase
    private let nicknameValidationService: NickNameValidationService

    // MARK: - Input
    @Published var isNicknameValid = false
    @Published var isDuplication = false
    @Published var nickname: String = ""
    @Published var isSignUpButtonEnabled = false

    // MARK: - Output
    let nicknameInput = PassthroughSubject<String, Never>()

    private var subscription = Set<AnyCancellable>()

    init(signUpUseCase: DefaultSignUpUseCase, nicknameValidationService: NickNameValidationService) {
        self.signUpUseCase = signUpUseCase
        self.nicknameValidationService = nicknameValidationService

        checkNicknameValidAndSave()
    }

    func checkNicknameValidAndSave() {
        nicknameInput
            .map { [weak self] nickname in
                return self?.validateNickname(nickname) ?? false
            }
            .assign(to: \.isNicknameValid, on: self)
            .store(in: &subscription)
    }

    // 서비스 불러오기
    func validateNickname(_ nickname: String) -> Bool {
        return nicknameValidationService.validateNickname(nickname)
    }

    // 닉네임 중복여부 확인
    func checkNicknameDuplication(nickname: String, completion: @escaping (Bool) -> Void) {
        signUpUseCase.checkNickname(nickname: nickname) { result in
            switch result {
            case .success(let isDuplicated):
                print("이메일 중복여부 : \(isDuplicated)")
                completion(isDuplicated)
            case .failure:
                self.isNicknameValid = false
                print("닉네임이 중복됩니다.")
                completion(false)
            }
        }
    }
}

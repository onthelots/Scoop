//
//  RegNicknameViewModel.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/20.
//

import Combine
import FirebaseAuth

final class RegNicknameViewModel: ObservableObject {
    internal let signUpUseCase: DefaultSignUpUseCase
    private let nicknameValidationService: NickNameValidationService

    let nicknameInput = PassthroughSubject<String, Never>()

    private var cancellables = Set<AnyCancellable>()

    @Published var isNicknameValid = false
    @Published var isDuplication = false
    @Published var nickname: String = ""
    @Published var isSignUpButtonEnabled = false

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


    // 패스워드 넘기기
    func setUserNickname(nickname: String) {
        self.nickname = nickname
    }

    // Checked Dubplication
    func executeNicknameDuplicationCheck(nickname: String, completion: @escaping (Bool) -> Void) {
            signUpUseCase.execute(nickname: nickname) { [weak self] result in
                switch result {
                case .success(let isDuplicated):
                    print("닉네임 중복여부 : \(isDuplicated)")
                    self?.isDuplication = isDuplicated
                    completion(isDuplicated)
                case .failure:
                    print("문제가 발생했습니다.")
                    completion(true)
                }
            }
        }
}

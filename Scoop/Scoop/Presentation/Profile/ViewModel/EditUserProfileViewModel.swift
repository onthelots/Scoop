//
//  EditUserProfileViewModel.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/09/12.
//

import Combine
import FirebaseAuth

final class EditUserProfileViewModel: ObservableObject {
    internal let userInfoUseCase: DefaultsUserInfoUseCase
    internal let signUpUseCase: DefaultSignUpUseCase
    private let nicknameValidationService: NickNameValidationService

    @Published var isNicknameValid = false
    @Published var isDuplication = false
    @Published var isSignUpButtonEnabled = false

    let nicknameInput = PassthroughSubject<String, Never>()
    let newNicknameInput = PassthroughSubject<String, Never>()

    private var subscription = Set<AnyCancellable>()

    init(userInfoUseCase: DefaultsUserInfoUseCase,signUpUseCase: DefaultSignUpUseCase, nicknameValidationService: NickNameValidationService) {
        self.userInfoUseCase = userInfoUseCase
        self.signUpUseCase = signUpUseCase
        self.nicknameValidationService = nicknameValidationService
        checkNicknameValidAndSave()
        saveUserNickname()
    }
    

    // 닉네임 사용 가능여부 체크
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

    // 닉네임 설정하기
    func saveUserNickname() {
        newNicknameInput
            .sink { nickname in
                guard let userId = Auth.auth().currentUser?.uid else {
                    return
                }
                self.userInfoUseCase.updateNickname(uid: userId, newNickname: nickname) { result in
                    switch result {
                    case .success:
                        print("변경된 닉네임: \(nickname)")
                    case .failure(let error):
                        print("Post 저장 실패: \(error.localizedDescription)")
                    }
                }
            }.store(in: &subscription)
    }
}

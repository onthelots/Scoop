//
//  RegisterWelcomeViewModel.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/21.
//

import Combine
import FirebaseAuth

final class RegisterWelcomeViewModel: ObservableObject {
    internal let signUpUseCase: DefaultSignUpUseCase
    internal let signInUseCase: DefaultSignInUseCase


    @Published var isLoggedIn: Bool = false

    let signUpButtonTapped = PassthroughSubject<UserInfo, Never>()
    private var subscription = Set<AnyCancellable>()

    // 1. signUpCases 초기화
    init(signUpUseCase: DefaultSignUpUseCase, signInUseCase: DefaultSignInUseCase) {
        self.signUpUseCase = signUpUseCase
        self.signInUseCase = signInUseCase

        setupBindings()
    }

    // 5. 전달받은 userInfo 정보를 바탕으로, 회원가입을 처리함
    func setupBindings() {
        signUpButtonTapped
            .sink { info in
                SensitiveInfoManager.create(key: "userEmail", password: info.email)
                SensitiveInfoManager.create(key: "userPassword", password: info.password ?? "")

                self.signUpUseCase.execute(email: info.email, password: info.password ?? "", location: info.location ?? "", nickname: info.nickname ?? "") { results in
                    switch results {
                    case .success:
                        self.signInUseCase.execute(email: info.email, password: info.password ?? "") { result in
                            switch result {
                            case .success:
                                self.isLoggedIn = true
                            case .failure(let error):
                                print("로그인에 실패했습니다 \(error)")
                                self.isLoggedIn = false
                            }
                        }
                    case .failure:
                        break
                    }
                }
            }.store(in: &subscription)
    }
}

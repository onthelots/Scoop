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

    let signUpButtonTapped = PassthroughSubject<UserInfo, Never>()
    private var subscription = Set<AnyCancellable>()

    // 1. signUpCases 초기화
    init(signUpUseCase: DefaultSignUpUseCase) {
        self.signUpUseCase = signUpUseCase
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
                        break
                    case .failure:
                        break
                    }
                }
            }.store(in: &subscription)
    }
}

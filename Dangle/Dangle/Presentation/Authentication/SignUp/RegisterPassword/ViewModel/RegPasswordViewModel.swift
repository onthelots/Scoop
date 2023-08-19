//
//  RegPasswordViewModel.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/20.
//

import Combine
import FirebaseAuth
import UIKit

final class RegPasswordViewModel: ObservableObject {
    private let signUpUseCase: DefaultSignUpUseCase

    let users: UserInfo // users(email, location) 내려받는 변수
    private var cancellables = Set<AnyCancellable>()

    init(signUpUseCase: DefaultSignUpUseCase, users: UserInfo) {
        self.signUpUseCase = signUpUseCase
        self.users = users
    }
}

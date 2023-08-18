//
//  EmailValidationService.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/18.
//

import Foundation

protocol EmailValidationService {
    func validateEmail(_ email: String) -> Bool
}

class DefaultEmailValidationService: EmailValidationService {
    func validateEmail(_ email: String) -> Bool {
        let emailPattern = "^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*\\.[a-zA-Z]{2,3}$"
        return NSPredicate(format: "SELF MATCHES %@", emailPattern).evaluate(with: email)
    }
}

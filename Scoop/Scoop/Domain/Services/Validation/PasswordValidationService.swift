//
//  PasswordValidationService.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/18.
//

import Foundation

protocol PasswordValidationService {
    func validatePassword(_ password: String) -> Bool
    func validatePasswordContainsLetter(_ password: String) -> Bool
    func validatePasswordContainsNumber(_ password: String) -> Bool
    func validatePasswordLength(_ password: String) -> Bool
}

class DefaultPasswordValidationService: PasswordValidationService {
    func validatePassword(_ password: String) -> Bool {
        return validatePasswordContainsLetter(password) &&
               validatePasswordContainsNumber(password) &&
               validatePasswordLength(password)
    }

    func validatePasswordContainsLetter(_ password: String) -> Bool {
        let letterCharacterSet = CharacterSet.letters
        return password.rangeOfCharacter(from: letterCharacterSet) != nil
    }

    func validatePasswordContainsNumber(_ password: String) -> Bool {
        let numberCharacterSet = CharacterSet.decimalDigits
        return password.rangeOfCharacter(from: numberCharacterSet) != nil
    }

    func validatePasswordLength(_ password: String) -> Bool {
        return (8...20).contains(password.count)
    }
}

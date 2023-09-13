//
//  NickNameValidationService.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/20.
//


import Foundation

protocol NickNameValidationService {
    func validateNickname(_ nickname: String) -> Bool
}

class DefaultNicknameValidationService: NickNameValidationService {
    func validateNickname(_ nickname: String) -> Bool {
        let minNicknameLength = 2
        let maxNicknameLength = 8

        let nicknameLength = nickname.count
        let characterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")

        return (minNicknameLength...maxNicknameLength).contains(nicknameLength) &&
               nickname.rangeOfCharacter(from: characterSet.inverted) == nil
    }
}

//
//  String+SignUpCheckValid.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/18.
//

import Foundation

extension String {
    func containsLetter() -> Bool {
        return self.rangeOfCharacter(from: .letters) != nil
    }

    func containsNumber() -> Bool {
        return self.rangeOfCharacter(from: .decimalDigits) != nil
    }

    func isValidLength() -> Bool {
        return (8...20).contains(self.count)
    }

    func isValidPassword() -> Bool {
        return containsLetter() && containsNumber() && isValidLength()
    }
}

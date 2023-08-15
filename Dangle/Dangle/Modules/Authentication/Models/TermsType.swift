//
//  TermsType.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/14.
//

import Foundation

enum TermsType: CaseIterable {
    case ageAgree
    case serviceAgree
    case sensitiveAgree

    var title: String {
        switch self {
        case .ageAgree:
            return "(필수) 만 114세 이상 가입 동의"
        case .serviceAgree:
            return "(필수) 서비스 이용 동의"
        case .sensitiveAgree:
            return "(필수) 개인정보 처리방침 동의"
        }
    }

    var description: String {
        switch self {
        case .ageAgree:
            return "(필수) 만 14세 이상 가입 동의"
        case .serviceAgree:
            return "(필수) 서비스 이용 동의"
        case .sensitiveAgree:
            return "(필수) 개인정보 처리방침 동의"
        }
    }

    var isChecked: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultsKeys.isCheckedKey(for: self))
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.isCheckedKey(for: self))
        }
    }
}

enum UserDefaultsKeys {
    static func isCheckedKey(for termType: TermsType) -> String {
        return "isChecked_\(termType)"
    }
}

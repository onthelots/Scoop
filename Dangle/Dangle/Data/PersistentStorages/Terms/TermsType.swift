//
//  TermsType.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/14.
//

import Foundation
import Combine

enum TermsType: CaseIterable {
    case ageAgree
    case serviceAgree
    case sensitiveAgree

    var title: String {
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

        // 가져오기 : 해당 Key에 저장된 bool 타입을 가져와서, isChecked bool 값이 반환됨
        // 즉, 아무것도 하지 않았다면, getter에 저장된 값도 없으니 false값이 할당될 것임
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultsKeys.isCheckedKey(for: self))
        }

        // 쓰기 : 이후, 해당 bool값이 해당 key에 다시 저장됨
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.isCheckedKey(for: self))
        }
    }
}

// 키를 생성하는
enum UserDefaultsKeys {
    static func isCheckedKey(for termType: TermsType) -> String {
        return "isChecked_\(termType)"
    }
}

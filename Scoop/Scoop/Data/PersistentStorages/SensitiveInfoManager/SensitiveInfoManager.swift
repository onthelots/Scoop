//
//  SensitiveInfoManager.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/13.
//

import Foundation
import Security


// MARK: - 로그인 시, 아이디 + 비밀번호 저장 / 사용자 위치정보 저장

class SensitiveInfoManager {

    // 데이터 추가하기
    class func create(key: String, password: String) {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword, // Password 형식
            kSecAttrAccount: key, // 저장할 이름
            kSecValueData: password.data(using: .utf8, allowLossyConversion: false) as Any // 유형별 저장할 Key 값
        ]

        SecItemDelete(query)

        let status = SecItemAdd(query, nil)
        assert(status == noErr, "Key 저장을 실패했습니다.")
    }

    class func read(key: String) -> String? {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)

        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data,
               let value = String(data: retrievedData, encoding: .utf8) {
                return value
            } else {
                print("Failed to convert data to string.")
                return nil
            }
        } else {
            print("Failed to load data, status code = \(status)")
            return nil
        }
    }

    class func delete(key: String) {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        let status = SecItemDelete(query)
        if status != noErr && status != errSecItemNotFound {
            print("Failed to delete the value, status code = \(status)")
        }
    }
}

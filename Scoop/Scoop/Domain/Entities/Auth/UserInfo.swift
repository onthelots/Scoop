//
//  User.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/18.
//

import Foundation
import Realm

// MARK: - Fetch Object
struct UserInfo: Codable {
    let email: String
    let password: String?
    let location: String?
    var nickname: String?
    let longitude: String?
    let latitude: String?
}

// MARK: - Realm
class RealmUserInfo: Object {
    @Persisted var email: String
    @Persisted var location: String?
    @Persisted var nickname: String?
    @Persisted var longitude: String?
    @Persisted var latitude: String?

    convenience init(userInfo: UserInfo) {
        self.init()
        self.email = userInfo.email
        self.location = userInfo.longitude
        self.nickname = userInfo.nickname
        self.longitude = userInfo.longitude
        self.latitude = userInfo.latitude
    }
}


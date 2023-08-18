//
//  User.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/18.
//

import Foundation

struct AuthUser: Codable {
    let user: [UserInfo]
}

struct UserInfo: Codable {
    let email: String
    let password: String
    let location: String?
    let nickname: String?
}

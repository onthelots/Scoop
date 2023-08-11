//
//  UserLocation.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/11.
//

import Foundation

// UserDefaults를 통해 저장할 유저 위치 구조체
struct UserLocation: Codable {
    var nearbyAddress: [UserLocationViewModel]?
    var address: String?
}

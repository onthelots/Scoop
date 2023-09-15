//
//  LocationDTO.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/09/05.
//

import Foundation

struct LocationDTO: Codable {
    let location: [LocationInfo]
}

// MARK: - Regcode
struct LocationInfo: Codable {
    let code: String
    let name: String
    let longitude: String?
    let latitude: String?
}

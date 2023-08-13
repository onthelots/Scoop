//
//  UserLocationViewModel.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/10.
//

import Foundation

struct UserLocationViewModel: Codable {
    let code: String // 행정동 코드
    let sido: String // 시도
    let siGunGu: String // 시군구
    let eupMyeonDong: String // 읍면동
}

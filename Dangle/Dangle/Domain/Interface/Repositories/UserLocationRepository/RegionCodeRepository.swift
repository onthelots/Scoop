//
//  RegionCodeRepository.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/16.
//

import Foundation

protocol RegionCodeRepository {
    func codeToRegionName(
        code: String,
        completion: @escaping (Result<RegionCode, Error>) -> Void)
}

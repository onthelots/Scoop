//
//  GecodeRepository.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/16.
//

import Foundation

protocol GeocodeRepository {
    func geocode(
        query: String,
        completion: @escaping (Result<Geocode, Error>) -> Void)
}

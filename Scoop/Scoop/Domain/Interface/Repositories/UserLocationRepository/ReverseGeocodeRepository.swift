//
//  ReverseGecodeRepository.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/16.
//

import Foundation
import CoreLocation

protocol ReverseGeocodeRepository {
    func reverseGeocode(
        coordinate: CLLocation,
        completion: @escaping (Result<ReverseGeocode, Error>) -> Void)
}

//
//  GeoLocationUseCase.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/16.
//

import Foundation
import CoreLocation

protocol UserLocationUseCase {

    // 리버스 지오코딩, 행정동 변환
    func execute(
        coordinate: CLLocation,
        completion: @escaping (Result<RegionCode, Error>) -> Void
    )

    // 검색 UseCase
    func execute(
        query: String,
        completion: @escaping (Result<Geocode, Error>) -> Void
    )
}

final class DefaultUserLocationUseCase: UserLocationUseCase {

    // Interface Repository의 로직(Protocol)을 가져옴 (구체적인 로직은 Data Repository에서 구현함)
    private let reverseGeocodeRepository: ReverseGeocodeRepository
    private let regionCodeRepository: RegionCodeRepository
    private let geocodeRepositoy: GeocodeRepository

    init(reverseGeocodeRepository: ReverseGeocodeRepository, regionCodeRepository: RegionCodeRepository, geocodeRepositoy: GeocodeRepository) {
        self.reverseGeocodeRepository = reverseGeocodeRepository
        self.regionCodeRepository = regionCodeRepository
        self.geocodeRepositoy = geocodeRepositoy
    }

    // 리버스 지오코딩, 행정동 변환
    func execute(
        coordinate: CLLocation,
        completion: @escaping (Result<RegionCode, Error>) -> Void
    ) {
        reverseGeocodeRepository.reverseGeocode(
            coordinate: coordinate
        ) { result in
            switch result {
            case .success(let reverseGeocode):
                if let regionCode = reverseGeocode.reverseDocument.first?.code {
                    self.regionCodeRepository.codeToRegionName(code: regionCode) { regionCodeResult in
                        switch regionCodeResult {
                        case .success(let regionCodeData):
                            completion(.success(regionCodeData))
                            self.regionCodeRepository.saveNearRegions(address: regionCodeData) { _ in
                                completion(regionCodeResult)
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    completion(.failure(UserLocationUseCaseError.invalidResponse))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // 검색 UseCase
    func execute(query: String, completion: @escaping (Result<Geocode, Error>) -> Void) {
        // Repository
        geocodeRepositoy.geocode(
            query: query
        ) { result in
            switch result {
            case .success(let geocode):
                completion(.success(geocode)) // viewModel에 해당 값을 전달함
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}

enum UserLocationUseCaseError: Error {
    case invalidResponse
}

struct UserLocationUseCaseRequestValue {
    let longitude: String
    let latitude: String
}

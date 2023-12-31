//
//  GeoLocationUseCase.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/16.
//

import Foundation
import CoreLocation

protocol UserLocationUseCase {
    func reverseGeocode(
        coordinate: CLLocation,
        completion: @escaping (Result<ReverseGeocode, Error>) -> Void
    )

    func geocode(
        query: String,
        completion: @escaping (Result<Geocode, Error>) -> Void
    )
}

final class DefaultUserLocationUseCase: UserLocationUseCase {

    private let reverseGeocodeRepository: ReverseGeocodeRepository
    private let geocodeRepositoy: GeocodeRepository

    init(reverseGeocodeRepository: ReverseGeocodeRepository, geocodeRepositoy: GeocodeRepository) {
        self.reverseGeocodeRepository = reverseGeocodeRepository
        self.geocodeRepositoy = geocodeRepositoy
    }

    // 리버스 지오코딩 (좌표 to 법점동)
    func reverseGeocode(
        coordinate: CLLocation,
        completion: @escaping (Result<ReverseGeocode, Error>) -> Void
    ) {
        reverseGeocodeRepository.reverseGeocode(
            coordinate: coordinate
        ) { result in
            switch result {
            case .success(let reverseGeocode):
                let filteredDocuments = reverseGeocode.reverseDocument.filter { $0.regionType == "B" }
                let filteredReverseGeocode = ReverseGeocode(reverseMeta: reverseGeocode.reverseMeta, reverseDocument: filteredDocuments)
                completion(.success(filteredReverseGeocode))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // 지오코딩 (검색 쿼리)
    func geocode(query: String, completion: @escaping (Result<Geocode, Error>) -> Void) {
        // Repository
        geocodeRepositoy.geocode(
            query: query
        ) { result in
            switch result {
            case .success(let geocode):
                let filteredDocuments = geocode.documents.filter { $0.address.region1DepthName == "서울" }
                let filteredGeocode = Geocode(meta: geocode.meta, documents: filteredDocuments)
                completion(.success(filteredGeocode))
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

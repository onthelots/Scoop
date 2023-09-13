//
//  DefaultReverseGeocodeRepository.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/16.
//

import Foundation
import Combine
import CoreLocation

final class DefaultReverseGeocodeRepository: ReverseGeocodeRepository {
    private let kakaoAPIKey = Bundle.main.kakaoAPI
    private let networkManager: NetworkService
    private let geocodeManager: GeocodingManager
    private var subscriptions = Set<AnyCancellable>()

    init(networkManager: NetworkService, geocodeManager: GeocodingManager) {
        self.networkManager = networkManager
        self.geocodeManager = geocodeManager
    }

    func reverseGeocode(
        coordinate: CLLocation,
        completion: @escaping (Result<ReverseGeocode, Error>) -> Void
    ) {
        let params = [
            "x": "\(coordinate.coordinate.longitude)",
            "y": "\(coordinate.coordinate.latitude)"
        ]
        let resource: Resource<ReverseGeocode> = Resource(
            base: geocodeManager.reverseGeocodeBaseURL,
            path: "",
            params: params,
            header: ["Authorization": "KakaoAK \(kakaoAPIKey)"]
        )

        networkManager.load(resource)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("error: \(error)")
                case .finished:
                    break
                }
            } receiveValue: { items in
                completion(.success(items))
            }.store(in: &subscriptions)
    }
}

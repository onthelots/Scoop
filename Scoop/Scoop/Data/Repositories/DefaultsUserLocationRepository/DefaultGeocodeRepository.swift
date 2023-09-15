//
//  DefaultGeocodeRepository.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/17.
//

import Foundation
import Combine
import CoreLocation

final class DefaultGeocodeRepository: GeocodeRepository {

    private let kakaoAPIKey = Bundle.main.kakaoAPI
    private let networkManager: NetworkService
    private let geocodeManager: GeocodingManager
    private var subscriptions = Set<AnyCancellable>()

    init(networkManager: NetworkService, geocodeManager: GeocodingManager) {
        self.networkManager = networkManager
        self.geocodeManager = geocodeManager
    }
    
    func geocode(
        query: String,
        completion: @escaping (Result<Geocode, Error>) -> Void
    ) {
        let params = [
            "query": "\(query)"
        ]

        let resource: Resource<Geocode> = Resource(
            base: geocodeManager.geocodeBaseURL,
            path: "",
            params: params,
            header: ["Authorization": "KakaoAK \(kakaoAPIKey)"]
        )

        networkManager.load(resource)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("--> 쿼리를 통해 지오코딩 데이터를 가져오는데 실패했습니다: \(error)")
                case .finished:
                    print("--> 쿼리릍 통해 지오코딩 데이터를 가져왔습니다.")
                }
            } receiveValue: { items in
                print("----> 지오코딩 주소값은? : \(String(describing: items.documents.first?.address.addressName)))")
                completion(.success(items))
            }.store(in: &subscriptions)
    }
}

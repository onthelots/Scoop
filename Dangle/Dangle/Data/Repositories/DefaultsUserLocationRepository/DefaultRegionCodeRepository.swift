//
//  DefaultRegionCodeRepository.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/16.
//

import Foundation
import Combine

final class DefaultRegionCodeRepository: RegionCodeRepository {
    private let networkManager: NetworkService
    private let geocodeManager: GeocodingManager
    private var subscriptions = Set<AnyCancellable>()

    init(networkManager: NetworkService, geocodeManager: GeocodingManager) {
        self.networkManager = networkManager
        self.geocodeManager = geocodeManager
    }

    func codeToRegionName(
        code: String,
        completion: @escaping (Result<RegionCode, Error>) -> Void
    ) {
        let regionCode: String = maskLastFiveCharacters(of: code)
        let params = [
            "regcode_pattern": regionCode,
            "is_ignore_zero": "true"
        ]

        let resource: Resource<RegionCode> = Resource(
            base: geocodeManager.regionCodeBaseURL,
            path: "",
            params: params
        )
        networkManager.load(resource)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("--> 행정동 데이터를 가져오는데 실패했습니다: \(error)")
                case .finished:
                    print("--> 행정동 지오코딩 데이터를 가져왔습니다.")
                }
            } receiveValue: { items in
                print("----> 행정동 수는? : \(String(describing: items.regcodes.count))")
                print("----> 행정동 값은? : \(String(describing: items.regcodes))")
                completion(.success(items))
            }.store(in: &subscriptions)
    }

    private func maskLastFiveCharacters(of input: String) -> String {
        guard input.count >= 5 else {
            return input
        }

        let startIndex = input.index(input.endIndex, offsetBy: -5)
        let maskedSubstring = String(repeating: "*", count: 5)

        return input.replacingCharacters(in: startIndex..<input.endIndex, with: maskedSubstring)
    }
}

//
//  UserLocationViewModel.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/16.
//

import Foundation
import Combine
import CoreLocation

final class UserLocationViewModel: ObservableObject {

    private let geoLocationUseCase: DefaultUserLocationUseCase

    @Published var userLocation: [Regcode] = []
    private var previousUserLocation: [Regcode] = []

    // Output
    let itemTapped = PassthroughSubject<Regcode, Never>()

    // 초기화
    init(geoLocationUseCase: DefaultUserLocationUseCase) {
        self.geoLocationUseCase = geoLocationUseCase
    }

    // 데이터를 가져오는 메서드
    func fetchUserLocation(coordinate: CLLocation) {
        geoLocationUseCase.execute(coordinate: coordinate) { [weak self] result in
            switch result {
            case .success(let address):
                self?.userLocation = address.regcodes
                self?.previousUserLocation = address.regcodes
                print("ViewModel에서 UseCase 호출")
            case .failure(let error):
                print("--> UseCase 메서드가 실패하였습니다: \(error)")
            }
        }
    }

    // 쿼리(검색)를 통해 주소를 가져오는 메서드
    func fetchUserSearchLocation(query: String) {
        // UseCase의 execute 메서드를 호출하여 데이터를 가져옵니다.
        geoLocationUseCase.execute(query: query) { [weak self] result in
            switch result {
            case .success(let address):
                self?.userLocation = address.documents.compactMap({ items in

                    guard let region3DepthName = items.address.region3DepthName,
                            !region3DepthName.isEmpty else {
                        return nil
                    }

                    guard let bCode = items.address.bCode,
                          !bCode.isEmpty else {
                        return nil
                    }

                    return Regcode(code: bCode, name: items.addressName, longitude: items.longitude, latitude: items.latitude)
                })
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }

    // 이전 사용자 위치 데이터를 반환하는 메서드
    func getPreviousUserLocation() -> [Regcode] {
        return previousUserLocation
    }
}

//
//  UserLocationViewModel.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/16.
//

import Foundation
import Combine
import CoreLocation

final class UserLocationViewModel: ObservableObject {

    private let geoLocationUseCase: DefaultUserLocationUseCase

    // MARK: - Input
    @Published var userLocation: [LocationInfo] = []
    @Published var isAvailableLocation: Bool = false // 사용자의 현재 위치가 서울시 인지 여부 파악
    private var previousUserLocation: [LocationInfo] = []

    // Output
    let itemTapped = PassthroughSubject<LocationInfo, Never>()

    // 초기화
    init(geoLocationUseCase: DefaultUserLocationUseCase) {
        self.geoLocationUseCase = geoLocationUseCase
    }

    // 데이터를 가져오는 메서드
    func fetchUserLocation(coordinate: CLLocation) {
        geoLocationUseCase.reverseGeocode(coordinate: coordinate) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let address):
                if address.reverseDocument.first?.region1DepthName == "서울특별시" {
                    // 즉시 받아오는 사용자의 위치정보 값
                    self.userLocation = address.reverseDocument.compactMap({ info in
                        return LocationInfo(code: info.code, name: info.addressName, longitude: String(info.longitude), latitude: String(info.latitude))
                    })

                    // 검색 시, 받아오는 사용자의 이전 위치정보 값
                    self.previousUserLocation = address.reverseDocument.compactMap({ info in
                        return LocationInfo(code: info.code, name: info.addressName, longitude: String(info.longitude), latitude: String(info.latitude))
                    })
                    self.isAvailableLocation = true
                } else {
                    self.isAvailableLocation = false
                }
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }

    // 쿼리(검색)를 통해 주소를 가져오는 메서드
    func fetchUserSearchLocation(query: String) {
        // UseCase의 execute 메서드를 호출하여 데이터를 가져옵니다.
        geoLocationUseCase.geocode(query: query) { [weak self] result in
            switch result {
            case .success(let address):
                self?.userLocation = address.documents.compactMap({ info in

                    guard let region3DepthName = info.address.region3DepthName,
                            !region3DepthName.isEmpty else {
                        return nil
                    }

                    guard let bCode = info.address.bCode,
                          !bCode.isEmpty else {
                        return nil
                    }

                    return LocationInfo(code: info.address.bCode ?? "", name: info.addressName, longitude: info.longitude, latitude: info.latitude)
                })
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }

    // 이전 사용자 위치 데이터를 반환하는 메서드 (검색창에 아무것도 적혀있지 않을 경우 표현)
    func getPreviousUserLocation() -> [LocationInfo] {
        return previousUserLocation
    }
}

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

    // Published 프로퍼티를 통해 데이터 변경을 자동으로 감지하고 업데이트됨을 구독자에게 알립니다.
    @Published var userLocation: [Regcode] = []
    private var previousUserLocation: [Regcode] = []

    // Output
    let itemTapped = PassthroughSubject<RegionCode, Never>()

    // 초기화
    init(geoLocationUseCase: DefaultUserLocationUseCase) {
        self.geoLocationUseCase = geoLocationUseCase
    }

    // 데이터를 가져오는 메서드
    func fetchUserLocation(coordinate: CLLocation) {
        // UseCase의 execute 메서드를 호출하여 데이터를 가져옵니다.
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

    func fetchUserSearchLocation(query: String) {
        // UseCase의 execute 메서드를 호출하여 데이터를 가져옵니다.
        geoLocationUseCase.execute(query: query) { [weak self] result in
            switch result {
            case .success(let address):
                self?.userLocation = address.documents.compactMap({ items in

                    // 주소 나타내는 로직 보여주기 (bCode 혹은 Hcode)
                    Regcode(code: items.address.bCode ?? "", name: items.addressName)
                })
                print("ViewModel에서 UseCase 호출")
            case .failure(let error):
                print("--> UseCase 메서드가 실패하였습니다: \(error)")
            }
        }
    }

    // 이전 사용자 위치 데이터를 반환하는 메서드
    func getPreviousUserLocation() -> [Regcode] {
        return previousUserLocation
    }
}

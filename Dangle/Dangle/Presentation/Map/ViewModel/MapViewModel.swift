//
//  MapViewModel.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

import Combine
import Foundation
import Firebase
import MapKit

class MapViewModel: ObservableObject {

    private let userInfoUseCase: UserInfoUseCase

    // Input
    @Published var userInfo: UserInfo!
    @Published var userLocation: [Regcode] = []

    // Output
    let itemTapped = PassthroughSubject<Regcode, Never>()

    //
    private var subscription = Set<AnyCancellable>()

    init(userInfoUseCase: UserInfoUseCase) {
        self.userInfoUseCase = userInfoUseCase
    }

    // 유저 정보 Coordinate 가져오기
    func userAllInfoFetch() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }

        userInfoUseCase.execute(userId: userId) { result in
            switch result {
            case .success(let userInfo):
                self.userInfo = userInfo
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }

    // Coordinate 변환
    private func fetchMyLocationCoordinate(latitude: String, longitude: String) -> CLLocationCoordinate2D? {
        guard let latitudeDouble = Double(latitude),
              let longitudeDouble = Double(longitude) else {
            return nil
        }
            let coordinate = CLLocationCoordinate2D(latitude: latitudeDouble, longitude: longitudeDouble)
            return coordinate
    }
}

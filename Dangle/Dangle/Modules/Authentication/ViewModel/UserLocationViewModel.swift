//
//  UserLocationViewModel.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/10.
//

import Foundation
import Combine

/*
 사용자의 현재위치를 저장하는 비즈니스 로직을 모두 담당
 1. 권한 허용시, reverse Geocoding을 통해 주소로 변환 후 -> 사용자가 Tapped -> Realm 혹은 UserDefaults로 저장 (Firestore에도 추가로 저장할 예정이니, 로직을 다시 한번 고민할 것)
 2. 권한 비 허용시, 검색결과(주소) 나타냄 -> 사용자가 Tapped -> Realm 혹은 UserDefaults로 저장 (Firestore에도 추가로 저장할 예정이니, 로직을 다시 한번 고민할 것)
 */

// MARK: - Sample viewModel
struct UserLocationViewModel: Codable {
    let sido: String
    let siGunGu: String
    let eupMyeonDong: String
    let ri: String
}


//final class UserLocationViewModel {
//
//    // Publisher 1. 네트워크 담당객체
//    let networkmanager: NetworkManager
//
//    // Publisher 2. ViewController에서 바인딩 할 예정인 값
//    @Published var userAddress: String = ""
//
//    // Publisher 3
//    let itemTapped = PassthroughSubject<String, Never>()
//
//    // Subscription (User Output)
//    var subscription = Set<AnyCancellable>()
//
//    init(networkmanager: NetworkManager) {
//        self.networkmanager = networkmanager
//    }
//
//    // Reverse Geocoding
//    func reverseGeocoding(coordinate: String) {
//        let params: [String: String] = [
//            "request": "coordsToaddr",          // 요청 유형: 좌표를 주소로 변환
//            "coords": coordinate,                   // 변환할 좌표값
//            "sourcecrs": "epsg:4326",             // 원본 좌표계
//            "output": "json",                   // 응답 형식은 JSON으로 지정
//            "orders": "legalcode,admcode"       // 응답 데이터의 순서 지정
//        ]
//
//        let resource: NetworkResource<String> = NetworkResource(
//            base: GeocodingManager.Constants.requestURL,
//            path: GeocodingManager.Constants.reverseGeocodePath,
//            params: params,
//            header: [
//                "X-NCP-APIGW-API-KEY-ID": GeocodingManager.Constants.clientID,
//                "X-NCP-APIGW-API-KEY": GeocodingManager.Constants.clientSecret
//            ]
//        )
//        networkmanager.load(resource)
//            .receive(on: RunLoop.main)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .failure(let error):
//                    print(error)
//                    print("데이터를 가져오지 못했습니다 : \(error.localizedDescription)")
//                case .finished:
//                    break
//                }
//            }, receiveValue: { address in
//                self.userAddress = address
//                print("저장된 사용자의 주소는? : \(address)")
//            })
//            .store(in: &subscription)
//    }
//}

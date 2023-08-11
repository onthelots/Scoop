//
//  CoreLocationManager.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/08.
//

import CoreLocation
import MapKit

protocol CoreLocationManagerDelegate: AnyObject {
    func updateLocation(coordinate: CLLocation)
    func showLocationServiceError()
    func presentLocationServicesEnabled()
}

class CoreLocationManager: NSObject, CLLocationManagerDelegate {

    static let shared = CoreLocationManager()
    weak var delegate: CoreLocationManagerDelegate?
    private var coreLocationManager: CLLocationManager

    override init() {
        coreLocationManager = CLLocationManager() // SubClass 프로퍼티 사전 초기화
        super.init()
        configureLocationManager()
    }

    func configureLocationManager() {
        coreLocationManager.delegate = self
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - 1. 권한이 바뀔 때(처음 시작, 혹은 임의로 재 설정 시) 마다 재 실행
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("1. 앱 권한이 변경되었습니다.")
        checkUserDeviceLocationServicesAuthorization()
    }

    // MARK: - 2. 사용자 디바이스의 위치서비스 활성화 여부를 확인
    func checkUserDeviceLocationServicesAuthorization() {
        DispatchQueue.global().async {
            guard CLLocationManager.locationServicesEnabled() else {
                self.delegate?.showLocationServiceError()
                return
            }
        }

        let authorizationStatus: CLAuthorizationStatus

        // 현재 위치서비스 사용자 권한 확인
        if #available(iOS 14.0, *) {
            authorizationStatus = coreLocationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }

        // authorizationStatus delived (to CheckUserCurrentLocationAuthorziaton)
        checkUserCurrentLocationAuthorization(authorizationStatus) // ⭐️ notDetermined를 전달하는 것이 올바른 상황
    }

    // MARK: - 3. 사용자 권한 확인 및 분기처리
    func checkUserCurrentLocationAuthorization(_ authoriezationStatus: CLAuthorizationStatus) {

        switch authoriezationStatus {
        case .notDetermined:
            print("3. 아직 결정되지 않았습니다. 허용 또는 비 허용을 선택해주세요")
            coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest // 정확도
            coreLocationManager.requestWhenInUseAuthorization() // 위치권한 요청 -> MARK 1(권한상태가 변경되므로, 다시 요청)
        case .restricted, .denied:
            print("3.앱 위치 서비스 비 허용, 설정으로")
//            delegate?.showLocationServiceError()
            self.delegate?.presentLocationServicesEnabled()

        case .authorizedAlways, .authorizedWhenInUse:
            coreLocationManager.startUpdatingLocation() // 지속적으로 사용자의 정보를 가져옴
            print("3. 앱 위치 서비스 허용")

        @unknown default:
            break
        }
    }

    // MARK: - 4. 사용자 위치정보 불러오기 완료
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 마지막 저장된 위치정보(CLLocation, corrdinate)
        if let coordinate = locations.last {
            self.delegate?.updateLocation(coordinate: coordinate)
        }
        
        // 현재위치, annotation 완료 후 위치 업데이트 중지
        coreLocationManager.stopUpdatingLocation()
    }


    func getCurrentLocation() -> CLLocationCoordinate2D? {
        let coordinate = coreLocationManager.location?.coordinate
        return coordinate
    }

    // MARK: - coodinate to String
    func coordinateToString(_ coordinate: CLLocationCoordinate2D) -> String {
        return "\(coordinate.longitude),\(coordinate.latitude)"
    }

    // MARK: - 위치 접근 실패(GPS를 사용할 수 없는 지역에 있는 등 문제)
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 서비스에 접근할 수 없습니다 \(error)")
    }

    func coordinateToString(_ coordinate: CLLocation) -> String {
        let longitutde = coordinate.coordinate.longitude
        let latitude = coordinate.coordinate.latitude
        let coordinateString: String = "\(longitutde),\(latitude)"
        return coordinateString
    }

    // MARK: - UserDefaults
    func cacheUserLocation(info: UserLocation, key: String) {
        let userlocation = UserDefaults.standard
        let encoder = JSONEncoder()

        if let encodeData = try? encoder.encode(info) {
            userlocation.set(encodeData, forKey: key)
        }
    }
}

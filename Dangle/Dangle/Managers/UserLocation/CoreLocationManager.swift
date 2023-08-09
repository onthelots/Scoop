//
//  CoreLocationManager.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/08.
//

import CoreLocation

protocol UserLocationViewModelDelegate: AnyObject {
    func updateLocation(address: String)
    func showLocationServiceError()
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()

    weak var delegate: UserLocationViewModelDelegate?

    private var coreLocationManager: CLLocationManager

    var currentLocation: CLLocation?
    var currentAddress: String?


    override init() {
        coreLocationManager = CLLocationManager() // SubClass 프로퍼티 사전 초기화
        super.init()
        configureLocationManager()
    }

    func configureLocationManager() {
        coreLocationManager.delegate = self
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("1. 앱 권한이 변경되었습니다.")
        checkUserDeviceLocationServicesAuthorization()
    }

    func checkUserDeviceLocationServicesAuthorization() {
        DispatchQueue.global().async {
            guard CLLocationManager.locationServicesEnabled() else {
                print("디바이스의 위치 서비스가 비 활성화 되어 있습니다. 설정창으로 이동합니다.")
                self.delegate?.showLocationServiceError()
                return
            }
        }
        let authorizationStatus: CLAuthorizationStatus

        // iOS 위치 서비스 확인
        if #available(iOS 14.0, *) {
            authorizationStatus = coreLocationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }

        // 현재 권한 상태값에 따라 분기처리를 실시하는 메서드를 실행함
        print("2. 디바이스 위치 서비스가 활성화 되어 있습니다. 앱 위치 서비스 권한여부로 이동합니다.")
        checkUserCurrentLocationAuthorization(authorizationStatus)
    }

    // MARK: - 1. 사용자 권한 확인 및 분기처리
    func checkUserCurrentLocationAuthorization(_ authorizationStatus: CLAuthorizationStatus) {
        let authorizationStatus = coreLocationManager.authorizationStatus

        switch authorizationStatus {
        case .notDetermined:
            print("3.아직 결정되지 않았습니다. 허용 또는 비 허용을 선택해주세요")
            coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest // 정확도
            coreLocationManager.requestWhenInUseAuthorization() // 위치권한 요청 -> MARK 1(권한상태가 변경되므로, 다시 요청)
            coreLocationManager.startUpdatingLocation() // 위치 접근 시작
        case .restricted, .denied:
            print("3.앱 위치 서비스 비 허용, 설정으로")
            delegate?.showLocationServiceError()

        case .authorizedAlways, .authorizedWhenInUse:
            print("3.앱 위치 서비스 허용")
            coreLocationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last {
            self.currentLocation = newLocation
            getCurrentAddress(location: newLocation)
        }
    }

    func getCurrentAddress(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                return
            }
            if let placemark = placemarks?.first {
                var address = ""

                if let administrativeArea = placemark.administrativeArea {
                    address += administrativeArea + " "
                }

                if let locality = placemark.locality {
                    address += locality + " "
                }

                if let subLocality = placemark.subLocality {
                    address += subLocality + " "
                }

                self.delegate?.updateLocation(address: address)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.showLocationServiceError()
    }
}

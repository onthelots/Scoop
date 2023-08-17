//
//  CoreLocationManager.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/08.
//

import CoreLocation
import Combine

protocol CoreLocationServiceDelegate: AnyObject {
    func updateLocation(coordinate: CLLocation)
    func showLocationServiceError()
    func presentDisallowedView()
}

class CoreLocationService: NSObject, CLLocationManagerDelegate {

    static let shared = CoreLocationService()

    weak var delegate: CoreLocationServiceDelegate?
    private var coreLocationManager: CLLocationManager

    // Create a subject to publish location updates
    private var locationSubject = PassthroughSubject<CLLocation, Never>()
    var locationPublisher: AnyPublisher<CLLocation, Never> {
        return locationSubject.eraseToAnyPublisher()
    }

    override init() {
        coreLocationManager = CLLocationManager()
        super.init()
        configureLocationManager()
    }

    func configureLocationManager() {
        coreLocationManager.delegate = self
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        print("1. coreLocationService가 시작되었습니다.")
    }

    // MARK: - Location Authorization Handling

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("1. 앱 권한이 변경되었습니다.")
        checkUserDeviceLocationServicesAuthorization()
    }

    func checkUserDeviceLocationServicesAuthorization() {
        DispatchQueue.global().async {
            guard CLLocationManager.locationServicesEnabled() else {
                DispatchQueue.main.async {
                    self.delegate?.presentDisallowedView()
                }
                return
            }
        }

        let authorizationStatus: CLAuthorizationStatus

        if #available(iOS 14.0, *) {
            authorizationStatus = coreLocationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }

        checkUserCurrentLocationAuthorization(authorizationStatus)
        print("2. 사용자의 권한 설정 상태는 다음과 같습니다 :  \(authorizationStatus.rawValue)")
    }

    func checkUserCurrentLocationAuthorization(_ authorizationStatus: CLAuthorizationStatus) {
        switch authorizationStatus {
        case .notDetermined:
            coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest
            coreLocationManager.requestWhenInUseAuthorization()
            print("3. 아직 결정되지 않았습니다. 허용 또는 비 허용을 선택해주세요")
        case .restricted, .denied:
            delegate?.presentDisallowedView()
            delegate?.showLocationServiceError()
            print("3.앱 위치 서비스 비 허용, 설정으로")
        case .authorizedAlways, .authorizedWhenInUse:
            coreLocationManager.startUpdatingLocation()
            print("3. 앱 위치 서비스 허용")

        @unknown default:
            break
        }
    }

    // MARK: - Location Update Handling
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 마지막 저장된 위치정보(CLLocation, corrdinate)
        if let coordinate = locations.last {
            locationSubject.send(coordinate) // Publish the updated location
            self.delegate?.updateLocation(coordinate: coordinate)
            print("4. updateLocation 델리게이트에 사용자의 좌표가 저장됩니다")
        }
        coreLocationManager.stopUpdatingLocation()
        print("5. 사용자 위치가 파악되었습니다. 업데이트를 중지합니다.")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 서비스에 접근할 수 없습니다 \(error)")
    }
}

//
//  CoreLocationManager.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/08.
//

import CoreLocation
import MapKit

protocol CoreLocationManagerDelegate: AnyObject {
//    func updateLocation(coordinate: String, address: String)
//    func updateLocation(coordinate: String)
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
//                self.delegate?.presentLocationServicesEnabled() //
                self.delegate?.showLocationServiceError()
                // 사용자 디바이스의 위치서비스가 활성화가 되어있지 않다면, 서비스 위치설정을 한 후, -> 다시 해당 화면으로 돌아갈 시, 다음 구문으로 돌아가서, 사용자 권한을 받는 메서드를 실행시켜야 함
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

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 마지막 저장된 위치정보(CLLocation, corrdinate)
        if let coordinate = locations.last {
            
            // coordinate to string
//            let coordinateString = self.coordinateToString(coordinate)
            
            // save address
//            self.delegate?.updateLocation(coordinate: coordinateString)
            self.delegate?.updateLocation(coordinate: coordinate)
        }
        
        // 현재위치, annotation 완료 후 위치 업데이트 중지
        coreLocationManager.stopUpdatingLocation()
        //        }
    }


//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        // 마지막 저장된 위치정보(CLLocation, corrdinate)
//        if let coordinate = locations.last?.coordinate {
//
//            // 현재 위치를 Address로 변환하는 메서드 실행
//            getCurrentAddress(location: CLLocation(latitude: coordinate.latitude,
//                                                   longitude: coordinate.longitude)
//            ) { address in
//
//                // annotation을 통해 MapView에서 활용 가능한 좌표, Address를 실행
//                self.setAnnotation(coorinate: coordinate, address: address)
//
//                // coordinate to string
//                let coordinateString = self.coordinateToString(coordinate)
//
//                // save address
//                self.delegate?.updateLocation(coordinate: coordinateString, address: address)
//            }
//
//            // 현재위치, annotation 완료 후 위치 업데이트 중지
//            coreLocationManager.stopUpdatingLocation()
//        }
//    }

    func getCurrentLocation() -> CLLocationCoordinate2D? {
        let coordinate = coreLocationManager.location?.coordinate
        return coordinate
    }

    func coordinateToString(_ coordinate: CLLocationCoordinate2D) -> String {
        return "\(coordinate.longitude),\(coordinate.latitude)"
    }

//    func getCurrentAddress(location: CLLocation, success: @escaping (String) -> Void) {
//        var currentAddress = ""
//        let geoCoder: CLGeocoder = CLGeocoder()
//        let location: CLLocation = location
//
//        // 한국어 주소 설정
//        let locale = Locale(identifier: "Ko-kr")
//
//        // 위도, 경도(coordinate)를 주소로 변환
//        geoCoder.reverseGeocodeLocation(location, preferredLocale: locale) { (placemarks, error) -> Void in
//
//            guard error == nil, let place = placemarks?.first else {
//                print("현재 위치주소를 파악할 수 없습니다.")
//                return
//            }
//
//            // 시,도
//            if let useradministrativeArea: String = place.administrativeArea {
//                currentAddress.append(useradministrativeArea + " ")
//            }
//
//            // cnrkrhksflwld
//            if let city: String = place.subAdministrativeArea {
//                currentAddress.append(city + " ")
//            }
//
//            // 도시?
//            if let locality: String = place.locality {
//                currentAddress.append(locality + " ")
//            }
//
//            if let thoroughfare: String = place.thoroughfare {
//                currentAddress.append(thoroughfare + " ")
//            }
//
//            // completion handler
//            success(currentAddress)
//        }
//    }

    // MapView에 Annotation 추가
    func setAnnotation(coorinate: CLLocationCoordinate2D, address: String) {
        let annotation = MKPointAnnotation()
        annotation.title = address
        annotation.coordinate = coorinate
        //                self.mapView?.addAnnotation(annotation)
        //                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        //                let region = MKCoordinateRegion(center: coorinate, span: span)
        //                self.mapView?.setRegion(region, animated: true)
    }

//    func getCurrentAddress(location: CLLocation) {
//        let geocoder = CLGeocoder()
//        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
//            guard let self = self else { return }
//            if let error = error {
//                print("Reverse geocoding error: \(error.localizedDescription)")
//                return
//            }
//            if let placemark = placemarks?.first {
//                var address = ""
//
//                if let administrativeArea = placemark.administrativeArea {
//                    address += administrativeArea + " "
//                }
//
//                if let locality = placemark.locality {
//                    address += locality + " "
//                }
//
//                if let subLocality = placemark.subLocality {
//                    address += subLocality + " "
//                }
//                self.currentAddress = address // 주소 업데이트
//                self.delegate?.updateLocation(address: address) // delegate
//                print(self.currentAddress ?? "현재 주소를 알 수 없습니다.")
//
//                // UI update
//                DispatchQueue.main.async {
//                    self.delegate?.updateUI()
//                }
//            }
//        }
//    }

    // MARK: - 위치 접근 실패(GPS를 사용할 수 없는 지역에 있는 등 문제)
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 서비스에 접근할 수 없습니다 \(error)")
    }
}

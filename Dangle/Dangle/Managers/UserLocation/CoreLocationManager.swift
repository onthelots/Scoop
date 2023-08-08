//
//  CoreLocationManager.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/08.
//

//import Foundation
//import CoreLocation
//import UIKit
//import MapKit
//
//class CoreLocationManager: NSObject, CLLocationManagerDelegate {
//    static let shared = CoreLocationManager()
//
//    var locationManager = CLLocationManager()
//
//    private override init() {
//        super.init()
//        setupLocationManager()
//    }
//
//    private func setupLocationManager() {
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        // 필요한 경우 추가적인 설정...
//    }
//
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        print("1. 앱에 대한 권한이 변경되었습니다. 위치 서비스 현황을 확인합니다.")
//        checkUserDeviceLocationServicesAuthorization()
//    }
//
//    // MARK: - 2. 사용자 디바이스의 위치서비스 활성화 여부를 확인
//    func checkUserDeviceLocationServicesAuthorization() {
//        DispatchQueue.global().async {
//            guard CLLocationManager.locationServicesEnabled() else {
//                print("2. 디바이스의 위치 서비스가 비 활성화 되어있습니다. 설정창으로 이동합니다.")
//                return
//            }
//        }
//
//        let authorizationStatus: CLAuthorizationStatus
//
//        // iOS 위치 서비스 확인
//        if #available(iOS 14.0, *) {
//            authorizationStatus = locationManager.authorizationStatus
//        } else {
//            authorizationStatus = CLLocationManager.authorizationStatus()
//        }
//
//        // 현재 권한 상태값에 따라 분기처리를 실시하는 메서드를 실행함
//        print("2. 디바이스 위치 서비스가 활성화 되어 있습니다. 앱 위치 서비스 권한여부로 이동합니다.")
//        checkUserCurrentLocationAuthorization(authorizationStatus)
//    }
//
//    // MARK: - 3. 사용자의 권한에 따른 분기처리
//    func checkUserCurrentLocationAuthorization(_ authorizationStatus: CLAuthorizationStatus) {
//
//        // 현재 위치상태에 따른 분기처리
//        switch authorizationStatus {
//
//            // 4-1. 결정되지 않았을 경우 (처음 권한을 부여하는 경우)
//        case .notDetermined:
//            print("3. 앱 위치서비스가 현재 설정되지 않았습니다. 허용 혹은 비허용을 선택해주세요.")
//            locationManager.desiredAccuracy = kCLLocationAccuracyBest // 정확도
//            locationManager.requestWhenInUseAuthorization() // 위치권한 요청 -> MARK 1(권한상태가 변경되므로, 다시 요청)
//            locationManager.startUpdatingLocation() // 위치 접근 시작
//
//            // 4-1. 결정되지 않았을 경우 (처음 권한을 부여하는 경우)
//        case .restricted, .denied:
//            print("4. 앱 위치서비스가 설정되지 않았습니다. 앱 위치권한 설정을 위해 설정창에서 허용을 선택해주세요.")
//
//            // 4-2. 권한을 허용했을 경우
//        case .authorizedAlways, .authorizedWhenInUse:
//            locationManager.startUpdatingLocation() // 현재의 위치를 가져옴(지속적으로)
//            print("권한 허용 여부 : \(locationManager.authorizationStatus)")
//            print("사용자의 현재 위치는? : \(String(describing: locationManager.location))")
//
//            // 4-3. default
//        @unknown default:
//            print("Default")
//        }
//    }
//
//    // MARK: - 4. (권한 허용 완료)위치정보를 승인한 경우(접근이 가능할 때) -> 전체적으로 권한을 허용했고, 사용자의 현재 위치를 가져올 수 있을때 수행
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("현재 위치정보가 업데이트 되었습니다 : \(locations)")
//
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
//                // address 값을 파악 후, 리스트로 뿌려주기
//                print("현재 사용자의 위치 : \(address), \(coordinate)")
//            }
//
//            // 현재위치, annotation 완료 후 위치 업데이트 중지
//            locationManager.stopUpdatingLocation()
//        }
//    }
//
//    // MARK: - 위치 접근 실패(GPS를 사용할 수 없는 지역에 있는 등 문제)
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print(#function, error)
//    }
//
//    // MARK: - 4. 현재 사용자의 위치를 주소값으로 변환
//
//    // (권한 허용 완료)사용자의 현재위치를 coordinate 값으로 변환
//    func getCurrentLocation() -> CLLocationCoordinate2D? {
//        let coordinate = locationManager.location?.coordinate
//        return coordinate
//    }
//
//    // (권한 허용 완료) 사용자의 coordinate 값을 Address로 변환
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
//            // 시,군,구
//            if let locality: String = place.locality {
//                currentAddress.append(locality + " ")
//            }
//
//            if let subLocality: String = place.subLocality {
//                currentAddress.append(subLocality + " ")
//            }
//
//            // completion handler
//            success(currentAddress)
//        }
//    }
//
//    // MapView에 Annotation 추가
//    func setAnnotation(coorinate: CLLocationCoordinate2D, address: String) {
//        let annotation = MKPointAnnotation()
//        annotation.title = address
//        annotation.coordinate = coorinate
////                self.mapView?.addAnnotation(annotation)
////                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
////                let region = MKCoordinateRegion(center: coorinate, span: span)
////                self.mapView?.setRegion(region, animated: true)
//    }
//}

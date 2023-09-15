//
//  MapView.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/09/01.
//
import Foundation
import UIKit
import MapKit

class MapView: UIView {

    // map 인스턴스 생성
    let map = MKMapView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(map)
        setupUI()
        cameraConstraining()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setupUI() {
        map.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.map.topAnchor.constraint(equalTo: self.topAnchor),
            self.map.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.map.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.map.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        ])
    }

    private func cameraConstraining() {
        let visibleMapRect = map.visibleMapRect

        // visibleMapRect의 중심 좌표 계산
        let midX = visibleMapRect.midX
        let midY = visibleMapRect.midY

        // 중심 좌표로 CLLocation 생성
        let centerCoordinate = MKMapPoint(x: midX, y: midY).coordinate
        let initialLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)

        let region = MKCoordinateRegion(
            center: initialLocation.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
        map.setCameraBoundary(
            MKMapView.CameraBoundary(coordinateRegion: region),
            animated: true
        )
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 20000)
        map.setCameraZoomRange(zoomRange, animated: true)
    }
}

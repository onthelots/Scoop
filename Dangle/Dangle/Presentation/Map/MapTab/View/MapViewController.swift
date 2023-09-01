//
//  MapViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/07.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    let mapView = MapView()
    let myLocation = CLLocationCoordinate2D(latitude: 37.51818789942772, longitude: 126.88541765534976)
    let locationManager = CLLocationManager()// 위치를 조종하게(?) 도와주는 로케이션 매니저를 하나 고용합시다.

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(mapView)
        mapView.map.setRegion(MKCoordinateRegion(center: myLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
        setupUI()
    }

    private func setupUI() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            mapView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            mapView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            mapView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
}

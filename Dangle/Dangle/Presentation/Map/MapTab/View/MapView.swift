//
//  MapView.swift
//  Dangle
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
}

//
//  SignUpTermsViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/10.
//

import UIKit

class SignUpTermsViewController: UIViewController {

    private let coreLocationManager = CoreLocationManager.shared

    // keywordLabel
    private let keywordLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.sizeToFit()
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let userlocation = coreLocationManager.getCachedUserLocation(key: "userLocation")
        title = userlocation?.eupMyeonDong

    }
}

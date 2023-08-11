//
//  SignUpTermsViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/10.
//

import UIKit

class SignUpTermsViewController: UIViewController {

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
        title = "서비스 이용약관 확인"
        view.backgroundColor = .systemBackground

    }

//    private func fetchUserDefaults(_ key: String) -> [UserLocation] {
//        if let data = UserDefaults.standard.object(forKey: key) as? Data {
//            let location = try? PropertyListDecoder().decode(UserLocation.self, from: data)
//            return location
//        }
//    }
}

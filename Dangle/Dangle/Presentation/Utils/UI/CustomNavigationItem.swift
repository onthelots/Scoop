//
//  CustomNavigationItem.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/18.
//

import Foundation
import UIKit


extension UIViewController {
    func setupBackButton() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(navigateBack))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func navigateBack() {
        navigationController?.popViewController(animated: true)
    }
}

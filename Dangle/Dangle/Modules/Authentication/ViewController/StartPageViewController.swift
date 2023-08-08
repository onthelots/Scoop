//
//  StartPageViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/07.
//

import UIKit

class StartPageViewController: UIViewController {

    // startPageView
    private let startPageView = StartPageView()

    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        startPageView.delegate = self
        view.backgroundColor = .systemBackground
        view.addSubview(startPageView)
        setupLayout()
    }

    // MARK: - setupLayouts
    private func setupLayout() {
        startPageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            startPageView.topAnchor.constraint(equalTo: view.topAnchor),
            startPageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            startPageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            startPageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - StartPageViewDelegate
extension StartPageViewController: StartPageViewDelegate {
    func signUpButtonDidTapped() {
        let userLocationViewController = UserLocationViewController()
        userLocationViewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(userLocationViewController, animated: true)
        print("내 동네 위치찾기~")
    }

    // signInButtonDidTapped
    func signInButtonDidTapped() {
        let signInViewController = SignInViewController()
        signInViewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(signInViewController, animated: true)
        print("로그인 하러가기~")
    }
}

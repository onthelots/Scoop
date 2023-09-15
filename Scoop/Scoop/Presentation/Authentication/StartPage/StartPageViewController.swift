//
//  StartPageViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/07.
//

import UIKit    
import CoreLocation

class StartPageViewController: UIViewController {

    // startPageView
    private let startPageView: StartPageView = {
        let view = StartPageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        startPageView.delegate = self
        view.backgroundColor = .tintColor
        view.addSubview(startPageView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        NSLayoutConstraint.activate([
            startPageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200),
            startPageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            startPageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            startPageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }
}

// MARK: - StartPageViewDelegate
extension StartPageViewController: StartPageViewDelegate {
    func signUpButtonDidTapped() {
        let viewModel = UserLocationViewModel(
            geoLocationUseCase: DefaultUserLocationUseCase(
                reverseGeocodeRepository: DefaultReverseGeocodeRepository(
                    networkManager: NetworkService(configuration: URLSessionConfiguration.default), // NetworkService 초기화
                    geocodeManager: GeocodingManager() // GeocodingManager 초기화
                ), geocodeRepositoy: DefaultGeocodeRepository(
                    networkManager: NetworkService(configuration: URLSessionConfiguration.default),
                    geocodeManager: GeocodingManager()
                )
            )
        )

        let userLocationViewController = UserLocationViewController(viewModel: viewModel)
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

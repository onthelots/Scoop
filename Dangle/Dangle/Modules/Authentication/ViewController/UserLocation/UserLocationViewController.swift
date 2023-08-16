//
//  UserLocationViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/08.
//

import UIKit
import CoreLocation

class UserLocationViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, SearchResultsViewControllerDelegate {

    // CoreLocationManager singleton
    private let coreLocationManager = CoreLocationManager.shared

    // 사용자 위치 저장값(법정동 코드, 이름)
    private var viewModel = [UserLocationViewModel]()
    // MARK: - Components (Views)

    // searchController
    lazy var searchController: UISearchController = {
        let viewController = UISearchController(searchResultsController: SearchResultsViewController())
        viewController.searchBar.placeholder = "동(읍,면) 이름으로 검색해주세요 (ex. 서초동)"

        if let textField = viewController.searchBar.value(forKey: "searchField") as? UITextField {
            if let placeholderLabel = textField.value(forKey: "placeholderLabel") as? UILabel {
                placeholderLabel.font = UIFont.systemFont(ofSize: 14) // 원하는 크기로 조정
                placeholderLabel.textColor = UIColor.gray // 원하는 색상으로 조정
            }
        }
        viewController.searchBar.searchBarStyle = .minimal
        viewController.definesPresentationContext = true
        return viewController
    }()

    // result tableView
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(
            UserLocationTableViewCell.self,
            forCellReuseIdentifier: UserLocationTableViewCell.identifier
        )
        tableView.isHidden = true
        return tableView
    }()

    // locationAuthDisallowedView
    private let locationAuthDisallowedView = LocationAuthDisallowedView()

    // MARK: - ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "위치찾기"
        view.backgroundColor = .systemBackground
        coreLocationManager.delegate = self

        // set searchBar
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController

        // Add TableView, delegate
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        // 1. 처음 뷰로 들어왔을 때
        coreLocationManager.checkUserDeviceLocationServicesAuthorization()
        setUplocationAuthDisallowedView() // Hidden이 초기값
    }


    // MARK: - View Layout
    override func viewDidLayoutSubviews() {

        // locationAuthDisallowedView
        locationAuthDisallowedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            locationAuthDisallowedView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationAuthDisallowedView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // tableview
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // setUplocationAuthDisallowedView
    private func setUplocationAuthDisallowedView() {

        view.addSubview(locationAuthDisallowedView)
        locationAuthDisallowedView.delegate = self
        navigationItem.searchController?.isActive = true
        // Set Text, ActionTitle
        locationAuthDisallowedView.configure(
            with: LocationAuthDisallowedViewModel(
                text: "현재 위치를 확인할 수 없습니다.\n주소 검색창을 통해 동네를 설정하세요.",
                actionTitle: "위치 권한 재 설정하기")
        )
    }

    // UISearchController 설정 (쿼리값에 따라, 컨트롤러(tableview Cell)을 업데이트
    func updateSearchResults(for searchController: UISearchController) {
        guard let resultsController = searchController.searchResultsController as? SearchResultsViewController,
              let query = searchController.searchBar.text,
              // query text의 공백을 모두 제거한 이후, 비어있지 않다면(Not Empty)
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        resultsController.delegate = self
        Geocoding().geocode(query: query) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    resultsController.update(with: response)
                    self?.tableView.reloadData()
                case .failure(let error):
                    // Handle geocoding error
                    print("Geocoding failed: \(error)")

                }
            }
        }
    }

    // 검색한 주소를 선택할 때 메서드
    func didTapResult(_ result: Document) {
        let userSelectedAddress: UserLocationViewModel = {
            if let bCode = result.address.bCode, !bCode.isEmpty,
               let hCode = result.address.hCode, !hCode.isEmpty {
                return UserLocationViewModel(code: bCode, name: result.addressName)
            } else if let bCode = result.address.bCode, !bCode.isEmpty {
                return UserLocationViewModel(code: bCode, name: result.addressName)
            } else if let hCode = result.address.hCode, !hCode.isEmpty {
                return UserLocationViewModel(code: hCode, name: result.addressName)
            } else {
                return UserLocationViewModel(code: "", name: result.addressName)
            }
        }()

        self.coreLocationManager.saveCacheUserLocation(viewModel: userSelectedAddress,
                                                       key: "StringdeselectedUserLocation")

        // MARK: - Naigation to SignUpView
        let termsViewController = TermsViewController()
        navigationController?.pushViewController(termsViewController, animated: true)
    }
}

// delegate pattern
extension UserLocationViewController: CoreLocationManagerDelegate {

    // 비허용 상태 - 서치바, presentLocationSearchView로 전환하기
    func presentDisallowedView() {
        self.locationAuthDisallowedView.isHidden = false
    }

    // LocationManager in UserAddress Delegate
    func updateLocation(coordinate: CLLocation) {
        ReverseGeocoding().reverseGeocode(location: coordinate) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let address):
                    let regionCode: String = address.reverseDocument.first?.code ?? ""

                    RegionCodeManager().convertCodeToRegionName(code: regionCode) { results in
                        switch results {
                        case .success(let result):
                            self?.viewModel = result.regcodes.compactMap({ region in
                                UserLocationViewModel(code: region.code,
                                                      name: region.name)
                            })

                            DispatchQueue.main.async {
                                self?.locationAuthDisallowedView.isHidden = true
                                self?.tableView.isHidden = false
                                self?.tableView.reloadData()
                            }
                        case .failure(let error):
                            print("코드값을 법정동으로 변환하지 못함 : \(error)")
                        }
                    }

                case .failure(let error):
                    print("사용자의 주소를 저장하지 못함 : \(error)")
                }
            }
        }
    }

    // LocationManager in Alert Delegate (권한 비 허용을 선택했을 때)
    func showLocationServiceError() {
        let alert = UIAlertController(
            title: "위치정보 이용",
            message: "위치 서비스를 사용할 수 없습니다.\n디바이스의 '설정 > 개인정보 보호'에서 위치 서비스를 켜주세요.",
            preferredStyle: .alert
        )

        let goToSettingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)

                // 🚫 한번 더 체크함
                self.coreLocationManager.checkUserDeviceLocationServicesAuthorization()
            }
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
        }

        alert.addAction(goToSettingsAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

// Extension1 : LocationDisallewdViewDelegate (View Delegate)
extension UserLocationViewController: LocationAuthDisallowedViewDelegate {
    func locationAuthDisallowedViewDidTapButton(_ view: LocationAuthDisallowedView) {
        showLocationServiceError()
    }
}

// Extension2 : Layout, DataSource
extension UserLocationViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }

    // cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserLocationTableViewCell.identifier,
                                                       for: indexPath) as? UserLocationTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(address: viewModel[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

    // didSelectedRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // MARK: - UserDefaults (deselectedUserLocation)
        let deselectedUserLocation = viewModel[indexPath.row]

        coreLocationManager.saveCacheUserLocation(viewModel: deselectedUserLocation, key: "deselectedUserLocation")

        // MARK: - Naigation to SignUpView
        let termsViewController = TermsViewController()
        navigationController?.pushViewController(termsViewController, animated: true)
    }
}

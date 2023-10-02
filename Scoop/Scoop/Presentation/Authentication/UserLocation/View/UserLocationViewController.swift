//
//  UserLocationViewController.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/08.
//

import UIKit
import Combine
import CoreLocation

class UserLocationViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {

    let viewModel: UserLocationViewModel!
    private let coreLocationService = CoreLocationService()
    private let userdefaultStorage = UserDefaultStorage<LocationInfo>()
    private var userlocation: [LocationInfo] = []
    private var subscription = Set<AnyCancellable>()

    private var locationAuthorizationStatus: Bool = false
    private var isAvailableLocation: Bool = false

    // MARK: - Components (Views)

    // searchController
    let searchController: UISearchController = {
        let searchBar = UISearchController()
        searchBar.searchBar.searchTextField.font = .systemFont(ofSize: 10)
        searchBar.searchBar.placeholder = "동명(읍, 면)으로 검색해주세요 (ex. 역삼동)"
        searchBar.searchBar.searchBarStyle = .minimal
        searchBar.definesPresentationContext = true
        return searchBar
    }()

    // Show Location Results TableView
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(
            UserLocationTableViewCell.self,
            forCellReuseIdentifier: UserLocationTableViewCell.identifier
        )
        tableView.isHidden = true
        return tableView
    }()

    private let locationAuthDisallowedView = LocationAuthDisallowedView() // 위치 권한이 거부된 경우 보여주는 뷰
    private let notAvailableLocationView = NotAvailableLocationView() // 위치 권한을 설정했으나, 서울시가 아닐 경우 나타나는 뷰

    init(viewModel: UserLocationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupBackButton()
        coreLocationService.delegate = self
        bind()
        coreLocationService.checkUserDeviceLocationServicesAuthorization()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }

    // MARK: - bind
    private func bind() {
        coreLocationService.isAuthorizationStatusAgree
            .receive(on: RunLoop.main)
            .sink { [weak self] authorizationStatus in
                guard let self = self else { return }
                locationAuthorizationStatus = authorizationStatus
                if locationAuthorizationStatus == false {
                    setUpLocationAuthDisallowedView()
                }
            }.store(in: &subscription)

        viewModel.$isAvailableLocation
            .receive(on: RunLoop.main)
            .sink { [weak self] availableLocation in
                guard let self = self else { return }
                isAvailableLocation = availableLocation
                if isAvailableLocation {
                    setUpTableView()
                    navigationItem.searchController?.isActive = true
                } else {
                    setUpNotAvailableLocationView()
                    navigationItem.searchController?.isActive = true
                }
            }.store(in: &subscription)

        viewModel.$userLocation
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                guard let self = self else { return }
                self.userlocation = items
                self.tableView.reloadData()
            }.store(in: &subscription)

        viewModel.itemTapped
            .sink { item in
                self.userdefaultStorage.saveCache(entity: item, key: "location")
                let viewController = TermsViewController()
                viewController.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(viewController, animated: true)
            }.store(in: &subscription)
    }

    private func setUpLocationAuthDisallowedView() {
        locationAuthDisallowedView.isHidden = false
        notAvailableLocationView.isHidden = true
        setUpTableView()
        view.addSubview(locationAuthDisallowedView)
        locationAuthDisallowedView.delegate = self
        locationAuthDisallowedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            locationAuthDisallowedView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationAuthDisallowedView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isHidden = false
        notAvailableLocationView.isHidden = true
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        tableView.reloadData()
    }

    private func setUpNotAvailableLocationView() {
        view.addSubview(notAvailableLocationView)
        notAvailableLocationView.translatesAutoresizingMaskIntoConstraints = false
        notAvailableLocationView.isHidden = false
        tableView.isHidden = true
        NSLayoutConstraint.activate([
            notAvailableLocationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notAvailableLocationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            userlocation = viewModel.getPreviousUserLocation()
            tableView.reloadData()
            return
        }
        locationAuthDisallowedView.isHidden = true
        notAvailableLocationView.isHidden = true
        viewModel.fetchUserSearchLocation(query: query) // ViewModel 실시
        tableView.isHidden = false
        tableView.reloadData()
    }
}

// MARK: - CoreLocationServiceDelegate
extension UserLocationViewController: CoreLocationServiceDelegate {
    func presentDisallowedView() {
        self.locationAuthDisallowedView.isHidden = false
        self.notAvailableLocationView.isHidden = true
    }

    func updateLocation(coordinate: CLLocation) {
        self.viewModel.fetchUserLocation(coordinate: coordinate)
    }

    func showLocationServiceError() {
        let alert = UIAlertController(
            title: "위치정보 이용",
            message: "위치 서비스를 사용할 수 없습니다.\n디바이스의 '설정 > 개인정보 보호'에서 위치 서비스를 켜주세요.",
            preferredStyle: .alert
        )

        let goToSettingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
                self.coreLocationService.checkUserDeviceLocationServicesAuthorization()
            }
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
        }

        alert.addAction(goToSettingsAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

}

// MARK: - LocationAuthDisallowedViewDelegate
extension UserLocationViewController: LocationAuthDisallowedViewDelegate {
    func locationAuthDisallowedViewDidTapButton(_ view: LocationAuthDisallowedView) {
        showLocationServiceError()
    }
}

// MARK: - UITableView Delegate, DataSource
extension UserLocationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userlocation.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserLocationTableViewCell.identifier, for: indexPath) as? UserLocationTableViewCell else {
            return UITableViewCell()
        }

        // ViewModel에서 가져온 데이터를 셀에 표시
        let address = userlocation[indexPath.row]
        cell.configure(address: address)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let address = userlocation[indexPath.row]
        viewModel.itemTapped.send(address)
    }
}

//
//  LocationSearchViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/04.
//

import UIKit
import Combine
import Firebase

protocol LocationSearchViewControllerDelegate: AnyObject {
    func locationSelected(_ location: SearchResult)
}

class LocationSearchViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    private var viewModel: ReviewViewModel!
    private var userLocation: [String] // 유저의 현재 좌표값
    private var searchLocations: [SearchResult] = []
    private var subscription = Set<AnyCancellable>()

    weak var delegate: LocationSearchViewControllerDelegate?

    // searchController
    private let searchController: UISearchController = {
        let searchBar = UISearchController()
        searchBar.searchBar.searchTextField.font = .systemFont(ofSize: 10)
        searchBar.searchBar.placeholder = "장소, 주소, 키워드 검색"
        searchBar.searchBar.searchBarStyle = .minimal
        searchBar.definesPresentationContext = true
        return searchBar
    }()

    // 결과를 보여주는 테이블 뷰
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(
            ReviewLocationTableViewCell.self,
            forCellReuseIdentifier: ReviewLocationTableViewCell.identifier
        )
        return tableView
    }()

    init(userLocation: [String]) {
        self.userLocation = userLocation
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        view.backgroundColor = .systemBackground
        initializeViewModel()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        bind()
        // Configure navigationItem SearchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }

    private func initializeViewModel() {
        let userLocationUseCase = DefaultPostUseCase(postRepository: DefaultPostRepository(networkManager: NetworkService(configuration: .default), geocodeManager: GeocodingManager(), firestore: Firestore.firestore()))
        viewModel = ReviewViewModel(postUseCase: userLocationUseCase)
    }

    private func bind() {
        // UserLocation (실시간 검색결과)를 selectedLocation으로 전달하고, tableView를 새로고침 (여기는 리스트임)
        viewModel.$searchResults
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                // 패치한 위치 아이템들을 searchLocations에 할당함
                self?.searchLocations = items
                self?.tableView.reloadData()
            }
            .store(in: &subscription)
    }

    // 검색 결과를 실시간으로 업데이트
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            tableView.reloadData()
            return
        }
        viewModel.fetchSearchLoction(
            query: query,
            longitude: userLocation[0],
            latitude: userLocation[1],
            radius: 10000
        )
        tableView.reloadData()
    }

    // MARK: - View Layout
    override func viewDidLayoutSubviews() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension LocationSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchLocations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReviewLocationTableViewCell.identifier, for: indexPath) as? ReviewLocationTableViewCell else {
            return UITableViewCell()
        }

        // ViewModel에서 가져온 데이터를 셀에 표시
        let address = searchLocations[indexPath.row]
        cell.configure(address: address)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    // 특정 Cell을 선택했을 경우, 결과값을 selectedLocationSubject로 전달
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let address = searchLocations[indexPath.row]
        self.delegate?.locationSelected(address) // delegate 패턴도 활용하고
        print("전달되는 address : \(address.addressName)")
        print("전달되는 x좌표 : \(address.longitude)")
        print("전달되는 y좌표 : \(address.latitude)")
        navigationController?.popViewController(animated: true)
    }
}

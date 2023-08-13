//
//  UserLocationViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/08.
//

import UIKit
import CoreLocation
import Combine


/*
 // --> 8월 12일
 [ ] 텍스트 좌측 정렬하기
 [ ] Geocoding Reverse 실시하기 -> 데이터를 임의 변수에 저장만 해두기
 [ ] 일반적인 Parsing을 통해 로직 설정하기 (현재, Combine을 비롯하여 제네릭 타입의
 [ ] Geocoding Reverse 데이터값을 분석, 인근의 동단위 까지 TableView에 뿌려주기

아니면, 그냥 위치만 디바이스에 저장한다음에, 메인뷰로 가서 -> 추후에 로그인을 진행할 수 있도록 할까?
파라미터에, 인근 행정동까지 가져오는 방법이 있을까?

 [ ] 해당 위치값을 Realm에 저장하기 -> 이전 뷰로 나갔다가 들어와도, 위치 데이터가 저장되어 있을 수 있도록 함
 [ ] 회원가입을 완료한 후, Firestore Database에 위치값을 저장하기
 [ ] 다른 ViewController에서도 해당 위치값을 사용할 수 있도록 하기

 // 나중에 실시할 것 (위치정보 허용을 하지 않았을 때, 임의로 주소를 검색하는 방식

 // --> 8월 13일
 [ ] SearchResults Cell 나타내기 (API Parsing) + 만약, 임의 검색을 실시할 경우, 기존의 AuthdisallowedView는 타이핑 시 잠깐 없어져야 함 (Spotify_App SearchVC 참고)
 [ ] 해당 위치값을 Realm에 저장, 추후 회원가입을 완료할 시 Firestore Database에 위치값 저장하기 (uses id 활용)
 [ ] 다음 회원가입 화면으로 넘어가는 버튼 생성하기
*/

class UserLocationViewController: UIViewController {

    // CoreLocationManager singleton
    private let coreLocationManager = CoreLocationManager.shared

    // 사용자 설정을 통해 결정될 좌표값 배열
    private var viewModel = [UserLocationViewModel]()

    // MARK: - Components (Views)
    // tableView
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
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
        title = "사용자 위치"
        view.backgroundColor = .systemBackground
        coreLocationManager.delegate = self

        // Add TableView, delegate
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        coreLocationManager.checkUserDeviceLocationServicesAuthorization()

        // Set AuthDisalloewdView, delegate
        setUplocationAuthDisallowedView()
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

        // Set Text, ActionTitle
        locationAuthDisallowedView.configure(
            with: LocationAuthDisallowedViewModel(
                text: "현재 위치를 확인할 수 없습니다.\n주소 검색창을 통해 동네를 설정하세요.",
                actionTitle: "위치 권한 재 설정하기")
        )
    }
}

// delegate pattern
extension UserLocationViewController: CoreLocationManagerDelegate {
    // When LocationService enabled, present 'DisallowedView'
    func presentLocationServicesEnabled() {
        self.locationAuthDisallowedView.isHidden = false
    }

    // LocationManager in UserAddress Delegate
    func updateLocation(coordinate: CLLocation) {
        ReverseGeocoding().reverseGeocode(location: coordinate) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let address):
                    self?.viewModel = address.reverseDocument.compactMap({ address in
                        UserLocationViewModel(code: address.code,
                                              sido: address.region2DepthName,
                                              siGunGu: address.region3DepthName,
                                              eupMyeonDong: address.region4DepthName)
                    })

                    self?.tableView.isHidden = false
                    self?.tableView.reloadData()

                case .failure(let error):
                    print("사용자의 주소를 저장하지 못함 : \(error)")
                }
            }
        }
    }

    // LocationManager in Alert Delegate
    func showLocationServiceError() {
        let alert = UIAlertController(
            title: "위치정보 이용",
            message: "위치 서비스를 사용할 수 없습니다.\n디바이스의 '설정 > 개인정보 보호'에서 위치 서비스를 켜주세요.",
            preferredStyle: .alert
        )

        let goToSettingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }

            // 임시로 적용 (위치서비스 설정을 실시한다는 가정하에, DisallowedAuthView를 감춤)
            self.locationAuthDisallowedView.isHidden = true
            self.tableView.reloadData()
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            DispatchQueue.main.async {
                self.locationAuthDisallowedView.isHidden = false
            }
        }

        alert.addAction(goToSettingsAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

// Extension1 : LocationDisallewdViewDelegate
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

        // MARK: - UserDefaults (Now Location)
        if let userLocation = viewModel.first {
            coreLocationManager.saveCacheUserLocation(viewModel: userLocation, key: "userLocation")
        }

        return cell
    }

    // didSelectedRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // MARK: - UserDefaults (deselectedUserLocation)
        let deselectedUserLocation = viewModel[indexPath.row]

        coreLocationManager.saveCacheUserLocation(viewModel: deselectedUserLocation, key: "deselectedUserLocation")

        // 검색쿼리
        Geocoding().geocode(query: "역삼동") { result in
            switch result {
            case .success(let address) :
                print("검색결과 : \(address.documents.first?.addressName)")
                
            case .failure(let error) :
                print(error)
            }
        }

        // MARK: - Naigation to SignUpView
        let signUpTermsViewController = SignUpTermsViewController()
        signUpTermsViewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(signUpTermsViewController, animated: true)
    }
}

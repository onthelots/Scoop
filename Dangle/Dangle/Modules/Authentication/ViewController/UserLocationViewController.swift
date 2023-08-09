//
//  UserLocationViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/08.
//

import UIKit


/*
 TODO List
 [ ] 권한을 설정하지 않았을 경우, 임시 View ("검색창에서 주소를 찾아주세요")
 [ ] 권한을 설정한 후, 현재 위치 화면에 나타내기 ("귀하의 현재 위치가 맞나요? 맞다면~ 다음으로, 틀리다면 검색창에서 주소를 찾아 선택해주세요~)
 [ ] SearchResults Cell 나타내기 (API Parsing)
 [ ] 해당 위치값을 Realm에 저장, 추후 회원가입을 완료할 시 Firestore Database에 위치값 저장하기 (uses id 활용)
 [ ] 다음 회원가입 화면으로 넘어가는 버튼 생성하기
*/

class UserLocationViewController: UIViewController {

    // MARK: - 위치 검색을 통해 Cell에서 선택하거나, 검색을 통해 선택하는 현재의 위치값이 저장되는 String (userAddress)
    private var userAddress: String = ""

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.sizeToFit()
        label.text = "현재 위치는?"
        label.textColor = .systemRed
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Location"
        view.backgroundColor = .systemBackground
        view.addSubview(label)

        LocationManager.shared.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension UserLocationViewController: UserLocationViewModelDelegate {
    func updateLocation(address: String) {
        DispatchQueue.main.async {
            self.userAddress = address
            self.label.text = self.userAddress
        }
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
            }
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)

        alert.addAction(goToSettingsAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
}

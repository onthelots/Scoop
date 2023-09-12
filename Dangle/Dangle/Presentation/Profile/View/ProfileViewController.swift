//
//  ProfileViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/07.
//

import Combine
import UIKit
import Firebase

class ProfileViewController: UIViewController {

    private var myPosts: [Post] = []
    private var userInfo: UserInfo!
    private var viewModel: ProfileViewModel!
    private var profileTableViewModel: ProfileTableViewModel = ProfileTableViewModel()
    private var profileTableItems: [ProfileTableItem] = []

    private var subscription = Set<AnyCancellable>()

    // MARK: - Components
    // 결과를 보여주는 테이블 뷰
    lazy var tableView: UITableView = {
        let tableView = UITableView(
            frame: .zero,
            style: .plain
        )
        tableView.register(ProfileTableViewCell.self,
                           forCellReuseIdentifier: ProfileTableViewCell.identifier)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.separatorInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private var userProfileView = UserProfileView()
    private var myPostView = MyPostView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        initalizerViewModel()
        initializerProfileTable()
        bind()
        setupUI()
        viewModel.userInfoFetch()
        userProfileView.delegate = self
        myPostView.delegate = self
    }
    // viewModel 초기화
    private func initalizerViewModel() {
        let userInfoUseCase = DefaultsUserInfoUseCase(userInfoRepository: DefaultsUserInfoRepository())
        let postUseCase = DefaultPostUseCase(postRepository: DefaultPostRepository(networkManager: NetworkService(configuration: .default), geocodeManager: GeocodingManager(), firestore: Firestore.firestore()))
        viewModel = ProfileViewModel(userInfoUseCase: userInfoUseCase, postUseCase: postUseCase)
    }

    private func initializerProfileTable() {
        profileTableViewModel.fetchData()
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func bind() {
        viewModel.$userInfo
            .receive(on: RunLoop.main)
            .sink { [weak self] userInfo in
                guard let self = self else { return }
                self.userInfo = userInfo
            }.store(in: &subscription)

        viewModel.editProfileTapped
            .sink { userInfo in
                let editUserProfileViewController = EditUserProfileViewController(userInfo: userInfo)
                editUserProfileViewController.title = "프로필 수정"
                editUserProfileViewController.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(editUserProfileViewController, animated: true)
            }.store(in: &subscription)

        viewModel.checkMyPostTapped
            .sink { myPotsts in
                let checkMyPostViewController = CheckMyPostViewController(myPosts: myPotsts)
                checkMyPostViewController.title = "내가 쓴 글"
                checkMyPostViewController.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(checkMyPostViewController, animated: true)
            }.store(in: &subscription)
        
        viewModel.$myPosts
            .sink { posts in
                self.myPosts = posts
            }.store(in: &subscription)

        profileTableViewModel.$items
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                self?.profileTableItems = items
                print("테이블 뷰 갯수 : \(self?.profileTableItems.count)")
                self?.tableView.reloadData()
            }.store(in: &subscription)
    }

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(userProfileView)
        view.addSubview(myPostView)

        userProfileView.translatesAutoresizingMaskIntoConstraints = false
        myPostView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            userProfileView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            userProfileView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            userProfileView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            userProfileView.heightAnchor.constraint(equalToConstant: 80),

            myPostView.topAnchor.constraint(equalTo: userProfileView.bottomAnchor, constant: 30),
            myPostView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            myPostView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            myPostView.heightAnchor.constraint(equalToConstant: 70),
            myPostView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),

            tableView.topAnchor.constraint(equalTo: myPostView.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            tableView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    private func updateUserProfileView(_ userInfo: UserInfo) {
        viewModel.userInfoFetch()
        self.userProfileView.userProfileConfigure(userInfo)
    }
}

extension ProfileViewController: UserProfileViewDelegate {
    func editButtonTapped() {
        viewModel.editProfileTapped.send(userInfo)

    }
}

extension ProfileViewController: MyPostViewDelegete {
    func myPostCheckButtonTapped() {
        viewModel.checkMyPostTapped.send(myPosts)
    }

    func customerServiceButtonTapped() {
        //
    }

    func noticeButtonTapped() {
        //
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileTableItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as? ProfileTableViewCell else {
            return UITableViewCell()
        }

        // 셀을 구성하고 ViewModel에서 가져온 항목을 전달합니다.
        let item = profileTableItems[indexPath.row]
        cell.configure(with: item)
        cell.backgroundColor = .systemBackground
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = profileTableItems[indexPath.row]

        switch item.action {
        case .openURL(let url):
            if let url = URL(string: url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }

        case .showAlert:
            let alert = UIAlertController(title: "로그아웃",
                                          message: "정말 로그아웃 하시겠습니까?",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "아니오",
                                          style: .cancel))
            alert.addAction(UIAlertAction(title: "네",
                                          style: .destructive, handler: { _ in
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                    UserDefaultStorage<String>().deleteCache(key: "email")
                    UserDefaultStorage<String>().deleteCache(key: "password")

                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        let startPageViewController = UINavigationController(rootViewController: StartPageViewController())
                        let transitionOptions: UIView.AnimationOptions = [.transitionCrossDissolve, .curveEaseInOut]
                        UIView.transition(with: sceneDelegate.window!, duration: 0.5, options: transitionOptions, animations: {
                            sceneDelegate.window?.rootViewController = startPageViewController
                            sceneDelegate.window?.makeKeyAndVisible()
                        }, completion: nil)
                    }
                } catch let signOutError as NSError {
                    print("로그아웃이 잘 되질 않았네요 : \(signOutError)")
                }
            }))
            present(alert, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

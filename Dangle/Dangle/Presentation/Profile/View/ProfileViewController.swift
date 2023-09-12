//
//  ProfileViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/07.
//

import Combine
import UIKit
import Firebase
import SafariServices

class ProfileViewController: UIViewController {

    private var myPosts: [Post] = []
    private var userInfo: UserInfo!
    private var profileViewModel: ProfileViewModel!
    private var profileTableViewModel: ProfileTableViewModel = ProfileTableViewModel()
    private var profileTableItems: [ProfileTableItem] = []

    private var subscription = Set<AnyCancellable>()

    // MARK: - Components
    // TableView
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

    // UserProfileView
    private var userProfileView = UserProfileView()
    // MyPostView
    private var myPostView = MyPostView()

    // MARK: - ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        initialViewModel()
        initialTableView()
        bind()
        setupUI()
        profileViewModel.userInfoFetch()
        userProfileView.delegate = self
        myPostView.delegate = self
    }

    // MARK: - Initial ViewModel
    private func initialViewModel() {
        let userInfoUseCase = DefaultsUserInfoUseCase(userInfoRepository: DefaultsUserInfoRepository())
        let postUseCase = DefaultPostUseCase(postRepository: DefaultPostRepository(networkManager: NetworkService(configuration: .default), geocodeManager: GeocodingManager(), firestore: Firestore.firestore()))
        profileViewModel = ProfileViewModel(userInfoUseCase: userInfoUseCase, postUseCase: postUseCase)
    }

    // MARK: - Initial TableView
    private func initialTableView() {
        profileTableViewModel.fetchData()
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - Bind()
    private func bind() {
        profileViewModel.$userInfo
            .receive(on: RunLoop.main)
            .sink { [weak self] userInfo in
                guard let self = self else { return }
                self.userInfo = userInfo
                guard let updateUserInfo = self.userInfo else { return }
                self.userProfileView.userProfileConfigure(updateUserInfo) // TODO: - 왜 View가 업데이트가 잘안되지?
            }.store(in: &subscription)

        profileViewModel.editProfileTapped
            .sink { userInfo in
                let editUserProfileViewController = EditUserProfileViewController(userInfo: userInfo)
                editUserProfileViewController.title = "프로필 수정"
                editUserProfileViewController.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(editUserProfileViewController, animated: true)
            }.store(in: &subscription)

        profileViewModel.checkMyPostTapped
            .sink { myPotsts in
                let checkMyPostViewController = CheckMyPostViewController(myPosts: myPotsts)
                checkMyPostViewController.title = "내가 쓴 글"
                checkMyPostViewController.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(checkMyPostViewController, animated: true)
            }.store(in: &subscription)
        
        profileViewModel.$myPosts
            .sink { posts in
                self.myPosts = posts
            }.store(in: &subscription)

        profileTableViewModel.$items
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                self?.profileTableItems = items
                self?.tableView.reloadData()
            }.store(in: &subscription)
    }

    // MARK: - setupUI()
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
        profileViewModel.userInfoFetch()
        self.userProfileView.userProfileConfigure(userInfo)
    }
}

extension ProfileViewController: UserProfileViewDelegate {
    func editButtonTapped() {
        profileViewModel.editProfileTapped.send(userInfo)
    }
}

extension ProfileViewController: MyPostViewDelegete {
    func myPostCheckButtonTapped() {
        profileViewModel.checkMyPostTapped.send(myPosts)
    }

    func customerServiceButtonTapped() {
        guard let url = URL(string: "https://naver.com") else {
            return
        }
        let safariViewController = SFSafariViewController(url: url)
        self.present(safariViewController, animated: true, completion: nil)
    }

    func noticeButtonTapped() {
        guard let url = URL(string: "https://naver.com") else {
            return
        }
        let safariViewController = SFSafariViewController(url: url)
        self.present(safariViewController, animated: true, completion: nil)
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
        let item = profileTableItems[indexPath.row]
        cell.configure(with: item)
        cell.backgroundColor = .systemBackground
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = profileTableItems[indexPath.row]

        // WebView Present
        switch item.action {
        case .openURL(let url):
            guard let url = URL(string: url) else {
                return
            }
            let safariViewController = SFSafariViewController(url: url)
            self.present(safariViewController, animated: true, completion: nil)

        // Logout button Tapped
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

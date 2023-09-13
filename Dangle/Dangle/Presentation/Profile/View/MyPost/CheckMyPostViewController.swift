//
//  CheckMyPostViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/12.
//

import Combine
import UIKit
import Firebase

class CheckMyPostViewController: UIViewController {

    private var viewModel: ProfileViewModel!
    private var selectedCategory: PostCategory?
    private var filteredPostsForCategory: [Post] = []
    private var subscription = Set<AnyCancellable>()

    // MARK: - Components
    private lazy var myPostCategoryView: MyPostCategoryView = {
        let myPostCategoryView = MyPostCategoryView()
        myPostCategoryView.delegate = self
        return myPostCategoryView
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView(
            frame: .zero,
            style: .plain
        )
        tableView.register(MyPostTableViewCell.self,
                           forCellReuseIdentifier: MyPostTableViewCell.identifier)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.separatorInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        tableView.backgroundColor = .systemBackground
        return tableView
    }()

    private var emptyMyPostToggleView = EmptyMyPostToggleView()

    init() {
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupBackButton()
        initalizerViewModel()
        setupUI()
        bind()
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categoryAndfetchPostInitializer()
    }

    // viewModel 초기화
    private func initalizerViewModel() {
        let userInfoUseCase = DefaultsUserInfoUseCase(userInfoRepository: DefaultsUserInfoRepository())
        let postUseCase = DefaultPostUseCase(postRepository: DefaultPostRepository(networkManager: NetworkService(configuration: .default), geocodeManager: GeocodingManager(), firestore: Firestore.firestore()))
        viewModel = ProfileViewModel(userInfoUseCase: userInfoUseCase, postUseCase: postUseCase)
    }


    // MARK: - view 진입시, 초기값 설정
    private func categoryAndfetchPostInitializer() {
        self.selectedCategory = .restaurant
        viewModel.initializerFetchMyPosts(category: .restaurant)
        self.myPostCategoryView.update(for: .restaurant)
    }

    private func setupUI() {
        view.addSubview(myPostCategoryView)
        view.addSubview(tableView)

        myPostCategoryView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            myPostCategoryView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            myPostCategoryView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            myPostCategoryView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            tableView.topAnchor.constraint(equalTo: myPostCategoryView.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }

    private func bind() {
        viewModel.myPostCategoryTapped
            .receive(on: RunLoop.main)
            .sink { [weak self] category in
                guard let self = self else { return }
                self.selectedCategory = category
            }.store(in: &subscription)

        // 데이터 필터링에 따라, snapshot을 업데이트
        viewModel.$filteredMyPostForCategory
            .receive(on: RunLoop.main)
            .sink { [weak self] post in
                guard let self = self else { return }
                print("데이터가 방출됨: \(post)")

                if post.isEmpty {
                    self.showEmptyMyPostToggleView() // 데이터가 없을 때 emptyPostToggleView를 표시
                    self.tableView.isHidden = true
                } else {
                    self.hideEmptyMyPostToggleView() // 데이터가 있을 때 emptyPostToggleView를 숨김
                    self.filteredPostsForCategory = post
                    self.tableView.isHidden = false
                    tableView.reloadData()
                }
            }.store(in: &subscription)
    }

    // ToogleView 나타내기
    private func showEmptyMyPostToggleView() {
        if emptyMyPostToggleView.superview == nil {
            view.addSubview(emptyMyPostToggleView)
            emptyMyPostToggleView.translatesAutoresizingMaskIntoConstraints = false

            // 애니메이션 효과 추가
            UIView.animate(withDuration: 0.3) {
                NSLayoutConstraint.activate([
                    self.emptyMyPostToggleView.heightAnchor.constraint(equalToConstant: 50),
                    self.emptyMyPostToggleView.centerYAnchor.constraint(equalTo: self.tableView.centerYAnchor),
                    self.emptyMyPostToggleView.leadingAnchor.constraint(equalTo: self.tableView.leadingAnchor),
                    self.emptyMyPostToggleView.trailingAnchor.constraint(equalTo: self.tableView.trailingAnchor)
                ])
                self.view.layoutIfNeeded()
            }
        }

        emptyMyPostToggleView.isHidden = false
    }

    private func hideEmptyMyPostToggleView() {
        self.emptyMyPostToggleView.isHidden = true
    }
}

// CategoryView Delegate
extension CheckMyPostViewController: MyPostCategoryViewDelegate {
    func myPostCategoryLabelTapped(_ gesture: UITapGestureRecognizer) {
        if let label = gesture.view as? UILabel,
           let selectedCategory = PostCategory(rawValue: label.text ?? "") {
            self.myPostCategoryView.update(for: selectedCategory) // 선택된 카테고리에 따라 view 업데이트
            self.viewModel.myPostCategoryTapped.send(selectedCategory) // 뷰 모델에 데이터 전달
            self.viewModel.fetchMyPosts(category: selectedCategory)
        }
    }
}

extension CheckMyPostViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("테이블 뷰의 갯수 : \(filteredPostsForCategory.count)")
        return filteredPostsForCategory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyPostTableViewCell.identifier, for: indexPath) as? MyPostTableViewCell else {
            return UITableViewCell()
        }
        let post = filteredPostsForCategory[indexPath.row]
        cell.configure(with: post)
        cell.backgroundColor = .systemBackground
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let postToDelete = filteredPostsForCategory[indexPath.row]
            viewModel.deletePost(post: postToDelete) { result in
                switch result {
                case .success:
                    self.filteredPostsForCategory.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                case .failure(let error):
                    print("error: \(error)")
                }
            }
        }
    }
}

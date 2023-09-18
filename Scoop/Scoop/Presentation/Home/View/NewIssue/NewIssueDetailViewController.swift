//
//  NewIssueDetailViewController.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/31.
//

import UIKit
import Combine

class NewIssueDetailViewController: UIViewController {

    let viewModel: NewIssueDetailViewModel!
    var subscripiton = Set<AnyCancellable>()

    // MARK: - Components
    private lazy var newIssueDetailView = NewIssueDetailView()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isDirectionalLockEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    init(viewModel: NewIssueDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        viewModel.fetch()
        bind()
        setupUI()
    }

    // MARK: - UI Setting
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(newIssueDetailView)
        newIssueDetailView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),

            newIssueDetailView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            newIssueDetailView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            newIssueDetailView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            newIssueDetailView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            newIssueDetailView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            newIssueDetailView.heightAnchor.constraint(greaterThanOrEqualTo: self.view.heightAnchor)
        ])
    }

    // ViewModel Binding
    private func bind() {
        viewModel.$newIssueDTO
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { items in
                self.newIssueDetailView.configure(newIssueDTO: items)
            }.store(in: &subscripiton)
    }
}

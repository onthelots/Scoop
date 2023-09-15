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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        viewModel.fetch()
        bind()
        setupUI()
    }

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

            // 1. width를 ScrollView와 동일하게 설정함으로서 수직스크롤을 적용
            newIssueDetailView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // 2. height는, ScrollView가 그려진 contentView(현재 ViewController의 View)로 설정하되, newIssueDetailView의 컨텐츠 크기에 따라 늘어날 수 있으므로 priority-같거나 큰-를 설정함)
            newIssueDetailView.heightAnchor.constraint(greaterThanOrEqualTo: self.view.heightAnchor)
        ])
    }

    // Bind
    private func bind() {
        viewModel.$newIssueDTO
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { items in
                self.newIssueDetailView.configure(newIssueDTO: items)
            }.store(in: &subscripiton)
    }
}

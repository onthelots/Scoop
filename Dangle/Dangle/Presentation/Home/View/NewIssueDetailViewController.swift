//
//  NewIssueDetailViewController.swift
//  Dangle
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
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    init(viewModel: NewIssueDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
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
            scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            newIssueDetailView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            newIssueDetailView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -10),
            newIssueDetailView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            newIssueDetailView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
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

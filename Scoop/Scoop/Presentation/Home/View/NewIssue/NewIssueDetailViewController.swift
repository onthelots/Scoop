//
//  NewIssueDetailViewController.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/31.
//

import UIKit
import Combine
import WebKit

class NewIssueDetailViewController: UIViewController, WKNavigationDelegate {

    let viewModel: NewIssueDetailViewModel!
    var subscripiton = Set<AnyCancellable>()

    // MARK: - Components
    private lazy var newIssueDetailView = NewIssueDetailView()

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
        bind()
        setupUI()
        viewModel.fetch()
    }

    // MARK: - UI Setting
    func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(newIssueDetailView)
        newIssueDetailView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newIssueDetailView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            newIssueDetailView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            newIssueDetailView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            newIssueDetailView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
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

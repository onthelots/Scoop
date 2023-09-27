//
//  NewIssueDetailViewController.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/31.
//

import UIKit
import Combine
import WebKit
import SafariServices

class NewIssueDetailViewController: UIViewController, WKNavigationDelegate, SFSafariViewControllerDelegate, UIDocumentInteractionControllerDelegate {

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
        newIssueDetailView.delegate = self
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

extension NewIssueDetailViewController: NewIssueDetailViewDelegate {
    func didTapExternalLink(url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.delegate = self
        present(safariViewController, animated: true, completion: nil)
    }

    func didTapFileLink(url: URL) {
        let downloadTask = URLSession.shared.downloadTask(with: url) { (location, _, error) in
            if let location = location {
                let documentController = UIDocumentInteractionController(url: location)
                documentController.delegate = self
                documentController.presentPreview(animated: true)
            } else if let error = error {
                print("다운로드 오류: \(error.localizedDescription)")
            }
        }
        downloadTask.resume()
    }
}

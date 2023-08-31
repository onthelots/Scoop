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

    init(viewModel: NewIssueDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }

    // Configure

    // Fetch

    // Bind
    private func bind() {
        viewModel.$newIssueDTO
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { items in
                // view configure에 할당
            }.store(in: &subscripiton)
    }
}

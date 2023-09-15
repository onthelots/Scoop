//
//  EventDetailViewController.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/25.
//

import UIKit
import Combine
import SafariServices

class EventDetailViewController: UIViewController {

    private let viewModel: EventDetailViewModel!
    private lazy var eventDetailView = EventDetailView()
    var subscripiton = Set<AnyCancellable>()

    init(viewModel: EventDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.fetch()
        bind()
        itemTapped()
        setupBackButton()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(eventDetailView)
        eventDetailView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            eventDetailView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            eventDetailView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            eventDetailView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            eventDetailView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Bind
    private func bind() {
        viewModel.$eventDetailDTO
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { items in
                self.eventDetailView.configure(eventDetail: items)
            }.store(in: &subscripiton)
    }

    private func itemTapped() {
        self.eventDetailView.webButtonView.nextButton.addTarget(self, action: #selector(openWebPage), for: .touchUpInside)
    }

    @objc private func openWebPage() {
        viewModel.openWebPage(from: self)
    }
}

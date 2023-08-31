//
//  EventDetailViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/25.
//

import UIKit
import SafariServices

class EventDetailViewController: UIViewController {

    private let viewModel: EventDetailViewModel
    private lazy var eventDetailView = EventDetailView()

    init(viewModel: EventDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
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

    private func bind() {
        self.eventDetailView.configure(
            eventDetail: viewModel.eventDetailItem
        )
        self.eventDetailView.webButtonView.nextButton.addTarget(self, action: #selector(openWebPage), for: .touchUpInside)
    }

    @objc private func openWebPage() {
        viewModel.openWebPage(from: self)
    }
}

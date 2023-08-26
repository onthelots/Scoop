//
//  EventDetailViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/25.
//

import UIKit
import SafariServices

class EventDetailViewController: UIViewController {

    private let eventDetailItem: EventDetailDTO

    private lazy var eventDetailView = EventDetailView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(eventDetailView)
        setupBackButton()
    }

    init(eventDetailItem: EventDetailDTO) {
        self.eventDetailItem = eventDetailItem
        super.init(nibName: nil, bundle: nil)

        bind()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

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
            eventDetail: EventDetailDTO(
                title: eventDetailItem.title,
                category: eventDetailItem.category,
                useTarget: eventDetailItem.useTarget,
                date: eventDetailItem.date,
                location: eventDetailItem.location,
                description: eventDetailItem.description,
                thumbNail: eventDetailItem.thumbNail,
                url: eventDetailItem.url
            )
        )
        self.eventDetailView.webButtonView.nextButton.addTarget(self, action: #selector(openWebPage), for: .touchUpInside)
    }

    @objc private func openWebPage() {
        guard let urlString = eventDetailItem.url,
              let url = URL(string: urlString) else {
            return
        }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
}

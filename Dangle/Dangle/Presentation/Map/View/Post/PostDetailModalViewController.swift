//
//  PostDetailModalViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/08.
//

import Combine
import UIKit
import MapKit
import Firebase
import CoreLocation

class PostDetailModalViewController: UIViewController {

    private var viewModel: MapDetailViewModel!

    private var storeUserReviews: [Post] = []

    private let tableView: UITableView = {
        let tableView = UITableView(
            frame: .zero,
            style: .grouped
        )
        // SearchResultDefaultTableViewCell
        tableView.register(PostTableViewCell.self,
                           forCellReuseIdentifier: PostTableViewCell.identifier)

        tableView.backgroundColor = .systemBackground
        return tableView
    }()

    private var subscription = Set<AnyCancellable>()


    init(storeUserReviews: [Post]) {
        self.storeUserReviews = storeUserReviews
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension PostDetailModalViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storeUserReviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell else {
            return UITableViewCell()
        }
        let post = storeUserReviews[indexPath.row]
        cell.configure(with: post)
        return cell
    }
}

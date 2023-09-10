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
    private var subscription = Set<AnyCancellable>()

    lazy var tableView: UITableView = {
        let tableView = UITableView(
            frame: .zero,
            style: .insetGrouped
        )
        // SearchResultDefaultTableViewCell
        tableView.register(PostTableViewCell.self,
                           forCellReuseIdentifier: PostTableViewCell.identifier)

        tableView.backgroundColor = .systemBackground
        return tableView
    }()

    private lazy var storeNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = .label
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var reviewCountLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = .tintColor
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let seperatedLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .quaternaryLabel
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

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
        view.backgroundColor = .systemBackground
        configure(storeUserReviews)
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func configure(_ posts: [Post]) {
        self.storeNameLabel.text = posts.first?.storeName
        self.reviewCountLabel.text = "\(posts.count)개 리뷰"
    }

    private func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)
        view.addSubview(storeNameLabel)
        view.addSubview(reviewCountLabel)
        view.addSubview(seperatedLineView)
        
        NSLayoutConstraint.activate([
            storeNameLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30),
            storeNameLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            storeNameLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),

            reviewCountLabel.topAnchor.constraint(equalTo: storeNameLabel.bottomAnchor, constant: 5),
            reviewCountLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            reviewCountLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),

            seperatedLineView.topAnchor.constraint(equalTo: reviewCountLabel.bottomAnchor, constant: 10),
            seperatedLineView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            seperatedLineView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            seperatedLineView.heightAnchor.constraint(equalToConstant: 2),

            tableView.topAnchor.constraint(equalTo: seperatedLineView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//
//  PostDetailModalViewController.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/09/08.
//

import Combine
import UIKit
import MapKit
import Firebase
import CoreLocation

class PostsModalViewController: UIViewController {
    private var storeUserReviews: [Post] = []

    lazy var tableView: UITableView = {
        let tableView = UITableView(
            frame: .zero,
            style: .plain
        )
        tableView.register(PostTableViewCell.self,
                           forCellReuseIdentifier: PostTableViewCell.identifier)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.separatorInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        tableView.backgroundColor = .systemBackground
        return tableView
    }()

    private lazy var storeNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = .tintColor
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = .quaternaryLabel
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var reviewCountLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = .label
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var seperateLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .ultraLight)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.text = "|"
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var addressLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = .label
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
        self.categoryLabel.text = posts.first?.category.rawValue
        self.reviewCountLabel.text = "리뷰 \(posts.count)"
        self.addressLabel.text = posts.first?.roadAddressName
    }

    private func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addSubview(storeNameLabel)
        view.addSubview(categoryLabel)
        view.addSubview(reviewCountLabel)
        view.addSubview(seperateLabel)
        view.addSubview(addressLabel)
        view.addSubview(seperatedLineView)
        
        NSLayoutConstraint.activate([
            storeNameLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30),
            storeNameLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),

            categoryLabel.centerYAnchor.constraint(equalTo: storeNameLabel.centerYAnchor),
            categoryLabel.leadingAnchor.constraint(equalTo: storeNameLabel.leadingAnchor, constant: 5),
            categoryLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),

            reviewCountLabel.topAnchor.constraint(equalTo: storeNameLabel.bottomAnchor, constant: 5),
            reviewCountLabel.leadingAnchor.constraint(equalTo: storeNameLabel.leadingAnchor),

            seperateLabel.centerYAnchor.constraint(equalTo: reviewCountLabel.centerYAnchor),
            seperateLabel.leadingAnchor.constraint(equalTo: reviewCountLabel.trailingAnchor, constant: 5),

            addressLabel.centerYAnchor.constraint(equalTo: seperateLabel.centerYAnchor),
            addressLabel.leadingAnchor.constraint(equalTo: seperateLabel.trailingAnchor, constant: 5),

            seperatedLineView.topAnchor.constraint(equalTo: reviewCountLabel.bottomAnchor, constant: 10),
            seperatedLineView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            seperatedLineView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            seperatedLineView.heightAnchor.constraint(equalToConstant: 2),

            tableView.topAnchor.constraint(equalTo: seperatedLineView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}

extension PostsModalViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storeUserReviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell else {
            return UITableViewCell()
        }
        let post = storeUserReviews[indexPath.row]
        cell.configure(with: post)
        cell.backgroundColor = .systemBackground
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storeUserReview = storeUserReviews
        print("선택된 리뷰 : \(storeUserReview)")
        let postDetailViewController = PostDetailViewController(storeUserReview: storeUserReview)
        postDetailViewController.modalPresentationStyle = .popover
        self.present(postDetailViewController, animated: true)
    }
}
